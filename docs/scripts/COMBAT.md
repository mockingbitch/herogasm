# COMBAT.md

# Combat System

> *"Victory belongs to the guild with the better strategy, not the highest Battle Power."*

---

# Design Philosophy

Combat được xây dựng dựa trên 5 nguyên tắc:

* Easy to Learn
* Hard to Master
* Fast Battle
* Strategic Team Building
* Infinite Replayability

Người chơi không điều khiển Hero trực tiếp.

Chiến thắng được quyết định bởi:

* Đội hình
* Vị trí
* Synergy
* Equipment
* Rune
* Talent
* AI
* Counter

---

# Battle Flow

```text
Prepare Team
        │
        ▼
Formation
        │
        ▼
Apply Buff
        │
        ▼
Battle Start
        │
        ▼
Auto Attack
        │
        ▼
Cast Skills
        │
        ▼
Ultimate
        │
        ▼
Victory / Defeat
        │
        ▼
Rewards
```

---

# Team Size

PvE

5 Hero

---

Arena

5 Hero

---

Guild War

3 Team

5 Hero / Team

---

Raid

10 Hero

---

World Boss

Guild cùng tham chiến.

---

# Formation

Mặc định

```text
[Tank]      [Tank]

[Warrior]   [Support]

[Mage]
```

Có thể mở thêm Formation đặc biệt.

Ví dụ

Arrow

Circle

Wall

Cross

Twin Front

Mỗi Formation có bonus riêng.

---

# Combat Speed

1x

2x

3x

4x

Skip Battle chỉ mở khi đã vượt màn.

---

# Target Priority

Tank

↓

Boss

↓

Elite

↓

Nearest Enemy

---

Warrior

↓

Nearest Enemy

---

Assassin

↓

Support

↓

Mage

↓

Ranger

---

Mage

↓

Largest Group

---

Support

↓

Lowest HP Ally

---

Summoner

↓

Triệu hồi khi đủ Mana

---

# Turn System

Combat chạy Real-Time.

Mỗi Hero có:

Attack Speed

↓

Cooldown

↓

Mana

↓

Skill Priority

Speed càng cao

↓

đánh càng nhanh

↓

hồi Mana nhanh hơn

↓

Ultimate sớm hơn

---

# Mana

Mana dùng để cast Skill.

Có thể nhận Mana từ:

* đánh thường
* nhận sát thương
* Passive
* Buff
* Equipment

Ultimate chỉ dùng khi đầy Mana.

---

# Hero States

Alive

Dead

Invisible

Invincible

Flying

Frozen

Stunned

Sleeping

Silenced

Taunted

Feared

Rooted

Knocked Up

Knocked Back

Burning

Poisoned

Bleeding

Shielded

---

# Buff

Attack Up

Defense Up

Magic Up

Speed Up

Critical Up

Healing Up

Shield

Damage Reduction

Life Steal

Mana Regen

Immunity

Revive

Reflect

---

# Debuff

Attack Down

Defense Down

Slow

Silence

Burn

Poison

Freeze

Stun

Blind

Fear

Curse

Armor Break

Magic Break

Healing Reduction

Mana Burn

---

# Damage Types

Physical

Magic

True Damage

Percent HP

Damage over Time

Reflect Damage

Execute Damage

---

# Combat Formula

Damage

↓

Critical

↓

Defense

↓

Resistance

↓

Shield

↓

HP

Thứ tự xử lý phải thống nhất để dễ cân bằng.

---

# Critical Hit

Nếu Crit xảy ra:

Damage × Crit Damage

Có thể bị:

* Block
* Dodge
* Reduce Crit

---

# Dodge

Nếu Dodge thành công

↓

Không nhận Damage

↓

Không nhận Debuff

Một số Skill

không thể Dodge.

---

# Block

Nếu Block

↓

Giảm Damage

↓

Vẫn nhận Debuff

---

# Shield

Shield luôn bị phá trước.

Shield không hồi HP.

Shield có thể cộng dồn hoặc ghi đè tùy loại.

---

# Crowd Control

CC chia thành 3 nhóm.

## Soft CC

Slow

Blind

Root

Silence

---

## Hard CC

Freeze

Stun

Sleep

Fear

Knock Up

---

## Ultimate CC

Time Stop

Petrify

Banish

Chỉ Boss hoặc Hero đặc biệt mới có.

---

# Skill Priority

Ultimate

↓

Active 3

↓

Active 2

↓

Active 1

↓

Basic Attack

Nếu Skill đang cooldown

↓

chuyển xuống Skill tiếp theo.

---

# AI Logic

Ví dụ Tank

```text
Boss?

YES

↓

Taunt

↓

Shield

↓

Basic Attack
```

Ví dụ Priest

```text
Ally HP < 30% ?

YES

↓

Heal

NO

↓

Buff

↓

Attack
```

Mỗi Hero có AI riêng.

---

# Combo System

Ví dụ

Freeze

*

Lightning

↓

Chain Lightning

---

Burn

*

Wind

↓

Fire Spread

---

Poison

*

Explosion

↓

Poison Explosion

---

Shield

*

Holy

↓

Blessed Shield

---

Combo giúp tăng chiều sâu chiến thuật.

---

# Counter System

Tank

↓

chặn Warrior

Warrior

↓

ép Ranger

Ranger

↓

tiêu diệt Mage

Mage

↓

đốt Tank

Assassin

↓

giết Support

Support

↓

giữ Tank sống

Không có đội hình bất bại.

---

# Positioning

Đây là yếu tố quan trọng.

Ví dụ

Tank luôn Front.

Mage nên Back.

Assassin có thể nhảy vào Backline.

Một Hero mạnh

đặt sai vị trí

↓

vẫn thua.

---

# Boss Mechanics

Boss KHÔNG chỉ có nhiều HP.

Boss có:

Phase

Special Attack

Summon

Enrage

Weak Point

Interrupt

Shield

Timer

Ví dụ

70%

↓

Triệu hồi lính

40%

↓

Phá sàn

10%

↓

Enrage

---

# Battle Rating

Sau trận hiển thị

Damage

Healing

Tank Damage

Damage Taken

Critical

Buff

Debuff

Crowd Control

MVP

Giúp người chơi tối ưu đội hình.

---

# Battle Time

Thông thường

30 ~ 90 giây

Raid

2 ~ 5 phút

World Boss

5 phút

Nếu quá thời gian

↓

Defeat

---

# Victory Conditions

PvE

Giết toàn bộ quái.

Arena

Tiêu diệt toàn bộ đối phương.

Raid

Giết Boss trước khi hết giờ.

Defense

Bảo vệ mục tiêu.

Escort

Hộ tống NPC.

Survival

Sống sót đủ thời gian.

---

# Replay

Sau trận

Người chơi có thể xem lại:

* Damage Timeline
* Skill Timeline
* Ultimate Timeline
* Death Timeline

Giúp phân tích chiến thuật.

---

# Balancing Principles

Không cân bằng bằng cách tăng Damage.

Ưu tiên điều chỉnh:

* Cooldown
* Mana Cost
* AI
* Buff Duration
* Debuff Duration
* Target Priority

Điều này giúp giữ bản sắc của Hero.

---

# Core Philosophy

Combat phải đảm bảo:

* Dễ hiểu với người mới.
* Có chiều sâu cho người chơi lâu năm.
* Battle Power chỉ là tham khảo.
* Chiến thuật và xây dựng đội hình luôn quan trọng hơn chỉ số.
* Không có Hero hoặc đội hình bất bại.
* Mỗi trận đấu đều có khả năng tạo ra kết quả khác nhau nhờ sự khác biệt về chiến thuật và cách xây dựng Guild.
