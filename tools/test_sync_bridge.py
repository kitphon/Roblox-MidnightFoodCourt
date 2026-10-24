"""Meaningful filesystem reconciliation tests; no real game profile is touched."""
import json
from pathlib import Path
import tempfile
import subprocess
import unittest
from sync_bridge import Engine, PLACE, UNIVERSE, decision, check, check_index, sha

class SyncTests(unittest.TestCase):
    def setUp(self):
        self.temp=tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root=Path(self.temp.name)
        (self.root/"studio-export").mkdir()
        (self.root/"src").mkdir()
        self.file=self.root/"src/Test.luau"
        self.file.write_text("return 1\n",encoding="utf-8")
        manifest={"scripts":[{"file":"src/Test.luau","class":"ModuleScript","parts":["ReplicatedStorage","Test"]}]}
        (self.root/"studio-export/manifest.json").write_text(json.dumps(manifest),encoding="utf-8")
        self.engine=Engine(self.root,git_check=False)

    def send(self,source="return 1\n",**kw):
        request={"placeId":PLACE,"gameId":UNIVERSE,"scripts":{"0":{"class":"ModuleScript","source":source}}}
        request.update(kw)
        return self.engine.exchange(request)

    def test_initial_difference_is_not_overwritten(self):
        self.assertEqual(self.send("return 2\n")["state"],"conflict")
        self.assertEqual(self.file.read_text(),"return 1\n")
        self.assertEqual(len(list((self.root/".sync/conflicts/0").glob("*.luau"))),2)

    def test_disk_to_studio_needs_acknowledgement(self):
        self.send()
        self.file.write_text("return 2\n")
        response=self.send()
        self.assertEqual(response["state"],"pending")
        self.assertEqual(response["updates"][0]["base"],"return 1\n")
        with self.assertRaises(ValueError): check(self.root)
        self.assertEqual(self.send("return 2\n")["state"],"synced")
        check(self.root)

    def test_studio_to_disk_with_backup_and_restart(self):
        self.send()
        self.send("return 3\n")
        self.assertEqual(self.file.read_text(),"return 3\n")
        self.assertEqual(len(list((self.root/".sync/backups/0").glob("*.luau"))),1)
        self.engine=Engine(self.root,git_check=False)
        self.assertEqual(self.send("return 3\n")["state"],"synced")

    def test_both_modified_conflicts_then_manual_agreement(self):
        self.send()
        self.file.write_text("return 4\n")
        self.assertEqual(self.send("return 5\n")["state"],"conflict")
        self.assertEqual(self.file.read_text(),"return 4\n")
        self.assertEqual(self.send("return 4\n")["state"],"synced")

    def test_play_does_not_write(self):
        self.send()
        self.assertEqual(self.send("return 9\n",running=True)["state"],"paused-play")
        self.assertEqual(self.file.read_text(),"return 1\n")

    def test_wrong_place_inventory_and_class_are_rejected(self):
        for change in ({"placeId":1},{"scripts":{}},{"scripts":{"0":{"class":"Script","source":"x"}}}):
            with self.subTest(change=change),self.assertRaises(ValueError): self.send(**change)

    def test_crlf_and_equal_concurrent_changes(self):
        self.assertEqual(self.send("return 1\r\n")["state"],"synced")
        self.file.write_text("return 7\n")
        self.assertEqual(self.send("return 7\n")["state"],"synced")

    def test_marker_and_scene_dirty_block(self):
        self.send()
        self.assertEqual(self.send("<<<<<<< conflict\n")["state"],"conflict")
        self.send(sceneDirty=True)
        with self.assertRaises(ValueError): check(self.root)

    def test_fresh_disk_edit_blocks_commit(self):
        self.send()
        self.file.write_text("return 8\n")
        with self.assertRaises(ValueError): check(self.root)

    def test_real_git_index_stale_content_rejected(self):
        def git(*args):
            subprocess.run(["git","-c","safe.directory="+self.root.as_posix(),*args],
                           cwd=self.root,check=True,capture_output=True)
        git("init","-q")
        git("add","src/Test.luau")
        self.file.write_text("return 3\n")
        status={"files":{"src/Test.luau":sha("return 3\n")}}
        with self.assertRaises(ValueError):
            check_index(self.root,status,self.engine.scripts)
        git("add","src/Test.luau")
        check_index(self.root,status,self.engine.scripts)

    def test_new_source_inventory_is_blocked(self):
        (self.root/"src/New.luau").write_text("return 1")
        with self.assertRaises(ValueError): self.send()

if __name__=="__main__":
    unittest.main()
