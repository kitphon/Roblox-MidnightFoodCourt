# Midnight Food Court — Project handoff
Current root: D:/Roblox-game/Midnight_Food_court.
เริ่มพัฒนา: ดับเบิลคลิก **Start Development.cmd** แล้วเปิดเกมใน Studio — ดู [SYNC.md](docs/SYNC.md) สำหรับระบบ sync โค้ดสองทางและการแก้ conflict
อัปเดต: 24 ตุลาคม 2026 (Asia/Bangkok)

เอกสารเริ่มต้นสำหรับคนและ AI ที่มาทำงานต่อ:
1. [HANDOFF.md](docs/HANDOFF.md) — สถานะปัจจุบัน โครงสร้างโค้ด วิธีทำงานและงานค้าง
2. [FEATURES.md](docs/FEATURES.md) — รายการระบบที่มีอยู่และวิธีใช้
3. [CHANGELOG.md](docs/CHANGELOG.md) — สิ่งที่พัฒนาและแก้ไขแล้ว
4. [TESTING.md](docs/TESTING.md) — หลักฐานการทดสอบ ข้อจำกัด และรายการทดสอบถัดไป
5. [AGENTS.md](AGENTS.md) — กติกาให้ agent อัปเดตเอกสารต่อ

## ข้อความเริ่มงานสำหรับ agent ถัดไป
> อ่าน AGENTS.md และ docs/HANDOFF.md ก่อน จากนั้นตรวจเกมใน Roblox Studio ผ่าน MCP ให้ตรง PlaceId 120399989321685 ตรวจสถานะโค้ดจริงและสิ่งที่ยังไม่ได้ Publish ก่อนแก้ไข ทำงานต่อจากรายการงานค้าง และอัปเดต FEATURES, CHANGELOG, TESTING และ HANDOFF เมื่อจบรอบ

หลัง migration นี้ ให้ maintain โค้ดใน src/ คู่กับ assets/ และเอกสาร โฟลเดอร์ outputs รุ่นเก่าไม่ใช่ source หลัก การ build ไม่ยืนยันว่าเวอร์ชันบน Roblox ตรงกับ repo


## Source และ Git
โค้ดล่าสุด 29 ไฟล์อยู่ใน src/ และโมเดล/ฉาก 33 ชุดอยู่ใน assets/ พร้อม default.project.json สำหรับ build กลับด้วย Rojo
อ่าน [DEVELOPMENT.md](docs/DEVELOPMENT.md) สำหรับ build, sync และ push
การ export/build ผ่านแล้ว แต่ยังไม่ได้เปิดไฟล์ build ทดสอบแยกจากเกมต้นทาง และยังไม่ได้ Publish จาก repo
