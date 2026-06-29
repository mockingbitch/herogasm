# PVP.md

# Player versus Player (PvP) System

> *"The strongest guild is not the one with the highest power, but the one that adapts the fastest."*

---

# Design Philosophy

PvP là bài kiểm tra cuối cùng của mọi hệ thống:

* Hero
* Equipment
* Rune
* Talent
* Formation
* AI
* Synergy

Mục tiêu:

* Chiến thuật thắng chỉ số.
* Meta luôn thay đổi.
* Không có đội hình bất bại.
* Người chơi luôn có lý do để thử nghiệm Build mới.

---

# PvP Modes

```text
Arena
│
├── Ranked Arena
├── Draft Arena
├── Team Arena
├── Guild War
├── King of the Hill
├── Survival Arena
├── Tournament
└── Cross Server Championship
```

---

# Arena

Chế độ PvP cơ bản.

* 5vs5
* Auto Battle
* AI điều khiển
* Chọn Formation trước trận

Mỗi ngày:

* 10 lượt miễn phí
* Có thể mua thêm bằng Gold hoặc Arena Ticket

---

# Ranked Arena

Xếp hạng theo MMR.

Season kéo dài:

8 tuần.

Người chơi leo hạng:

```text
Bronze

↓

Silver

↓

Gold

↓

Platinum

↓

Diamond

↓

Master

↓

Grandmaster

↓

Legend
```

Reward theo:

* Rank cuối Season.
* Rank cao nhất.
* Số trận thắng.

---

# Draft Arena

Không sử dụng toàn bộ Hero.

Quy trình:

```text
Ban Hero

↓

Ban Hero

↓

Pick Hero

↓

Pick Hero

↓

Pick Hero

↓

Pick Hero

↓

Formation

↓

Battle
```

Luật:

* Mỗi Hero chỉ được chọn một lần.
* Hero bị Ban không thể dùng.

Đây là chế độ eSports chính.

---

# Team Arena

Người chơi xây dựng:

3 đội hình.

```text
Team A

5 Hero

↓

Team B

5 Hero

↓

Team C

5 Hero
```

Đội thắng nhiều trận hơn sẽ chiến thắng.

Yêu cầu bộ sưu tập Hero đa dạng.

---

# Guild War

Guild đấu Guild.

Mỗi thành viên:

* Đăng ký đội hình phòng thủ.
* Chọn mục tiêu để tấn công.

Guild thắng nhận:

* Guild Coin.
* Guild EXP.
* Seasonal Reward.

---

# King of the Hill

Người thắng:

Ở lại giữ ngôi.

Người thua:

Bị thay thế.

Càng giữ lâu:

Reward càng lớn.

---

# Survival Arena

Một đội hình chiến đấu liên tục.

Không hồi HP giữa các trận.

Chỉ hồi một phần Mana.

Người chơi phải cân bằng:

* Damage.
* Heal.
* Độ bền.

---

# Tournament

Giải đấu loại trực tiếp.

```text
64

↓

32

↓

16

↓

8

↓

4

↓

2

↓

Champion
```

Có thể:

* PvP thật.
* AI Replay.

---

# Cross Server Championship

Top Guild hoặc Top Player của nhiều server.

Thi đấu theo Season.

Đây là nội dung End Game.

---

# Matchmaking

Hệ thống ưu tiên:

* Rank.
* MMR.
* Win Rate.
* Battle Power (tham khảo).

Không ghép chỉ theo Power.

---

# Battle Rules

Mỗi trận:

* 90 giây.
* Auto Battle.
* AI theo Build của Hero.

Nếu hết giờ:

Bên còn nhiều HP hơn thắng.

---

# Formation

Formation ảnh hưởng:

* Buff.
* Target Priority.
* Khoảng cách.
* Hiệu quả Skill.

Đặt sai vị trí có thể thua dù Battle Power cao hơn.

---

# Draft Rules

Draft Arena có Rotation.

Ví dụ:

Season này:

Không dùng:

* Fire Mage.
* Dragon Knight.

Hoặc:

Buff:

* Ranger.
* Poison Build.

Meta thay đổi tự nhiên.

---

# Seasonal PvP Modifiers

Mỗi Season có Modifier.

Ví dụ

## Season of Storm

Lightning Damage +20%.

---

## Season of Frost

Freeze Duration +15%.

---

## Season of Blood

Lifesteal +10%.

---

## Season of Shadows

Assassin nhận thêm Energy khi hạ gục mục tiêu.

Không cần buff trực tiếp Hero.

---

# PvP Maps

Không chỉ một Arena.

Ví dụ

Forest

↓

Tăng Dodge.

---

Lava

↓

Burn Damage.

---

Ruins

↓

Có cột chắn tầm nhìn.

---

Frozen Lake

↓

Giảm Speed.

---

Temple

↓

Có Healing Shrine.

Map tạo thêm yếu tố chiến thuật.

---

# Replay System

Sau trận có thể xem:

* Replay.
* Damage Chart.
* Heal Chart.
* Timeline Skill.
* AI Decision.
* MVP.

Người chơi học hỏi từ thất bại.

---

# Spectator Mode

Có thể xem:

* Top Rank.
* Guild War.
* Tournament.
* Chung kết Season.

Replay được lưu trong thời gian giới hạn.

---

# PvP Currency

Arena Coin.

Guild Coin.

Season Token.

Champion Medal.

Dùng để mua:

* Cosmetic.
* Equipment Material.
* Rune.
* Avatar.
* Skin.

Không bán Hero độc quyền.

---

# Anti-Meta System

Nếu một đội hình chiếm hơn 60% Top Rank:

Hệ thống sẽ:

* Thay đổi Seasonal Modifier.
* Thay đổi Rotation.
* Thay đổi Dungeon Buff.

Không nerf Hero ngay lập tức.

---

# Fair Play

Không sử dụng:

* Pay-to-Win Buff.
* VIP Combat Bonus.
* Exclusive PvP Hero.

Mọi người đều dùng chung luật.

---

# Ranking Rewards

Reward theo:

* Rank.
* League.
* Win Streak.
* Participation.

Không chỉ Top 1 mới có thưởng.

---

# Daily Missions

Ví dụ:

* Thắng 3 Arena.
* Thắng 1 Draft.
* Tham gia Guild War.
* Xem Replay.
* Đổi Formation.

Khuyến khích người chơi trải nghiệm nhiều chế độ.

---

# PvP Progression

```text
Arena

↓

Ranked

↓

Draft

↓

Guild War

↓

Tournament

↓

Cross Server

↓

World Championship
```

---

# Balance Philosophy

Không cân bằng bằng cách:

* Buff Damage.
* Nerf Damage.

Ưu tiên:

* AI.
* Cooldown.
* Mana.
* Seasonal Modifier.
* Map.
* Draft Rotation.

Hero vẫn giữ bản sắc.

---

# Design Principles

* Không có Hero bắt buộc phải sở hữu.
* Không có đội hình bất bại.
* Build thông minh luôn có cơ hội thắng Build mạnh hơn.
* Người chơi có nhiều mục tiêu PvP ở mọi cấp độ.
* Meta thay đổi theo Season thay vì thay đổi Hero liên tục.

---

# Future Expansion

Có thể bổ sung:

* 2vs2 Guild Duo Arena.
* Battle Royale Arena.
* Auto Chess Mode.
* Hero Brawl (Hero ngẫu nhiên).
* Weekly Rule Arena.
* Capture the Crystal.
* King Boss PvP (hai đội cùng đánh Boss, đội gây nhiều sát thương hơn thắng).
* Asynchronous Arena với AI học từ hành vi người chơi.
* PvP Sandbox cho phép tạo luật chơi riêng.

Mục tiêu là xây dựng một hệ sinh thái PvP có chiều sâu, đủ hấp dẫn để duy trì cộng đồng cạnh tranh trong nhiều năm mà không phụ thuộc vào việc liên tục tăng Battle Power.
