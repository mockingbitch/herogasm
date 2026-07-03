# Herogasm
## Game Design Document (Version 0.1)

> *Game living-world idle RPG. Bối cảnh diễn ra tại vương quốc đổ nát **Kingdom of Ashes** trên lục địa Azerath.*

---

# 1. Giới thiệu

## Thể loại

- RPG
- Idle / AFK
- Hero Collection
- Team Building
- Guild War
- Auto Battle

## Platform

- Android
- iOS

## Engine

Godot 4.x

---

# 2. Ý tưởng cốt lõi

Người chơi không điều khiển một Hero.

Người chơi vào vai **Guild Master**, người lãnh đạo một tổ chức lính đánh thuê trong thời kỳ hỗn loạn.

Nhiệm vụ của người chơi:

- Tuyển Hero
- Quản lý Hero
- Xây dựng đội hình
- Farm trang bị
- Săn Boss
- Tham gia Guild
- PvP
- Leo Rank
- Hoàn thành Event theo mùa

Mục tiêu cuối cùng:

Xây dựng Guild mạnh nhất lục địa.

---

# 3. Bối cảnh

500 năm trước...

Ma Vương bị đánh bại.

Các Hero huyền thoại biến mất.

Các quốc gia bắt đầu chiến tranh giành tài nguyên.

Quái vật xuất hiện khắp nơi.

Guild lính đánh thuê trở thành lực lượng bảo vệ nhân loại.

Người chơi chính là Guild Master của một Guild nhỏ đang trên đường trở thành huyền thoại.

---

# 4. Gameplay Loop

Đăng nhập

↓

Thu tài nguyên

↓

Nhận Quest

↓

Sắp đội hình

↓

Auto Battle

↓

Nhận trang bị

↓

Nâng cấp Hero

↓

Mở Map mới

↓

Đánh Boss

↓

Guild

↓

Arena

↓

Event

↓

Lặp lại

---

# 5. Hệ thống Hero

## Vai trò

Tank

- Knight
- Guardian
- Paladin

---

Warrior

- Warrior
- Berserker
- Samurai

---

Assassin

- Rogue
- Ninja
- Shadow Hunter

---

Ranger

- Archer
- Hunter
- Elf Archer

---

Mage

- Fire Mage
- Ice Mage
- Lightning Mage
- Necromancer

---

Support

- Priest
- Bishop
- Druid
- Oracle

---

Summoner

- Beast Master
- Demon Caller

---

# 6. Chủng tộc (Race)

Human

- HP cao

Elf

- Crit cao

Orc

- Attack cao

Dwarf

- Armor cao

Undead

- Lifesteal

Angel

- Heal mạnh

Demon

- Damage lớn

Dragonkin

- Skill Damage

---

# 7. Chỉ số

## Cơ bản

- HP
- Attack
- Defense

## Nâng cao

- Magic Attack
- Magic Defense
- Speed
- Critical Rate
- Critical Damage
- Accuracy
- Evasion
- Lifesteal
- Block
- Skill Haste
- Resistance
- Penetration

---

# 8. Skill

Mỗi Hero có:

- 1 Passive
- 3 Active Skill
- 1 Ultimate

Ví dụ Assassin

Passive

+20% Damage khi đánh sau lưng

Skill 1

Dash

Skill 2

Poison Blade

Skill 3

Smoke Bomb

Ultimate

Shadow Kill

---

# 9. Vai trò trong chiến đấu

Tank

- Đỡ đòn
- Thu hút mục tiêu

Warrior

- DPS ổn định

Assassin

- Tiêu diệt tuyến sau

Mage

- Damage diện rộng

Priest

- Heal
- Buff

Archer

- Damage tầm xa

Summoner

- Triệu hồi sinh vật

---

# 10. Formation

Ví dụ

Front

Tank Tank

Middle

Warrior Priest

Back

Mage Archer

---

# 11. Synergy

> ⚠️ **Superseded bởi `TEAMBUILD.md`.** Số dưới đây là bản phác cũ dùng đường cong **tăng dần** (ép mono, chống đa dạng). Hệ synergy chính thức (giảm dần + coalition + band cân bằng + sim) nằm ở `TEAMBUILD.md`.

## Theo Race

3 Human

+5% HP

5 Human

+15% HP

---

3 Elf

+10% Crit

---

3 Orc

+10% Attack

---

## Theo Class

2 Tank

+Armor

3 Mage

+Mana Regen

3 Assassin

+Crit Damage

2 Priest

+Healing

---

# 12. Trang bị

Weapon

Helmet

Armor

Gloves

Boots

Ring

Necklace

Relic

Pet

---

## Độ hiếm

Common

Rare

Epic

Legend

Mythic

Ancient

---

## Random Option

Ví dụ

Sword

Attack +300

Random

+15 Speed

+10 Crit

+Fire Damage

---

# 13. Rune

Fire Rune

Ice Rune

Wind Rune

Shadow Rune

Holy Rune

Poison Rune

Rune giúp Hero có nhiều hướng build khác nhau.

---

# 14. Talent Tree

Ví dụ Warrior

Defense

Attack

Berserk

Người chơi chọn 1 nhánh để phát triển.

---

# 15. Pet

Pet không trực tiếp chiến đấu.

Pet chỉ hỗ trợ.

Ví dụ

Wolf

+Attack

Phoenix

Hồi sinh

Dragon

+Fire Damage

Fairy

+Heal

---

# 16. Dungeon

## Normal Dungeon

Farm EXP

---

## Equipment Dungeon

Farm đồ

---

## Gold Dungeon

Farm vàng

---

## Rune Dungeon

Farm Rune

---

## Endless Dungeon

Leo tầng vô hạn

---

# 17. Boss

World Boss

Guild Boss

Raid Boss

Hidden Boss

Season Boss

Boss có nhiều phase.

Không chỉ đơn giản là nhiều HP.

---

# 18. PvP

Arena

1vs1

---

3vs3

---

Guild War

---

Rank Season

---

Draft Mode

Ban Hero

Pick Hero

Đội hình thay đổi theo từng trận.

---

# 19. Guild

Guild Level

Guild Tech

Guild Boss

Guild War

Guild Shop

Guild Quest

Guild Ranking

---

# 20. Event

Halloween

Christmas

Tết

Summer

Anniversary

Mỗi Event có:

- Boss riêng
- Skin riêng
- Trang bị giới hạn
- Battle Pass

---

# 21. Battle Power

Battle Power chỉ phản ánh sức mạnh tổng thể.

Không quyết định thắng thua.

Ví dụ

800.000 Power

vẫn có thể thắng

900.000 Power

nếu build đội hình hợp lý.

---

# 22. Hệ thống cân bằng

Không có Hero mạnh nhất.

Mỗi Hero mạnh trong một tình huống.

Ví dụ

Fire Mage

★★★★★ Farm

★★ PvP

★★★★ Guild Boss

---

Ice Mage

★★★ Farm

★★★★★ PvP

★★ Raid

---

Necromancer

★★ Farm

★★★★★ Boss

★★ PvP

Meta thay đổi theo Season.

Không buff Hero trực tiếp.

Chỉ:

- Buff Rune
- Buff Equipment
- Buff Synergy
- Buff Dungeon

---

# 23. Monetization

Không Pay to Win.

Bán:

- Skin
- Battle Pass
- Avatar
- Khung Chat
- Hiệu ứng
- Đổi tên
- Vé tăng tốc

Không bán Hero bắt buộc phải có.

---

# 24. End Game

- Endless Dungeon
- World Boss
- Guild War
- Arena Season
- Mythic Raid
- Hero Awakening
- Collection
- Achievement
- Hidden Boss

---

# 25. Điểm khác biệt

Không phải game điều khiển Hero.

Là game quản lý Guild.

Người chơi sở hữu hàng chục Hero.

Mỗi trận chỉ chọn 5 Hero.

Hero có:

- Tính cách
- Quan hệ
- Sở thích
- Điểm mạnh
- Điểm yếu

Mỗi Hero đều có giá trị trong từng chế độ chơi khác nhau.

Không tồn tại Hero mạnh nhất.

Chiến thuật mới là yếu tố quyết định chiến thắng.

---

# 26. Tầm nhìn dài hạn

Game được xây dựng theo mô hình Live Service.

Mỗi Season (2~3 tháng):

- Hero mới
- Boss mới
- Dungeon mới
- Rune mới
- Meta mới
- Battle Pass
- Event

Mục tiêu:

Tạo một game có thể phát triển liên tục trong nhiều năm mà không xảy ra tình trạng Power Creep quá mức.