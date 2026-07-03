# OVERVIEW.md — Tổng quan Herogasm (Mermaid)

> Sơ đồ tổng quan **living-world Idle/AFK RPG** (cảm hứng Evil Hunter Tycoon).
> Xem cùng [FLOW.md](FLOW.md) (hành trình chi tiết) và [README.md](README.md).
> Nguyên tắc tối thượng: **Offline-First** — mọi hệ chơi trọn offline, online chỉ là lớp sync.

---

## 1) Cấu trúc game + Vòng lặp lõi

```mermaid
flowchart TB
  LORD["🛡️ NGƯỜI CHƠI = LÃNH CHÚA<br/>avatar quản lý · KHÔNG combat · Lord Level = cổng mở khoá"]

  subgraph TOWN["🏰 THÀNH TRÌ (màn Thành)"]
    GUILD["Guild · quest/roster"]
    INN["Nhà Trọ · hồi HP/mood"]
    SMITH["Xưởng Rèn · sửa/nâng đồ"]
    SHOP["Cửa Hàng · potion/đồ"]
    TRAIN["Luyện Binh · train"]
    ALCHEMY["Dược Sư · trị thương"]
    KITCHEN["Bếp · food"]
    ALTAR["🔮 Đài Triệu Hồi · Gacha"]
  end

  GATE{{"🌀 Cổng Dịch Chuyển"}}

  subgraph FIELD["🌲 BÃI SĂN (màn khác)"]
    ROAM["Quái roaming"]
    BATTLE["Auto-Battle<br/>Battle Engine tất định (seeded)"]
    LOOT["Loot · gold/material/shard/đồ"]
    ROAM --> BATTLE --> LOOT
  end

  subgraph HERO["🦸 HERO (đơn vị chiến đấu)"]
    RANK["Rank S/A/B/C/D = ngân sách chỉ số"]
    IDENT["Class × Race × Growth Star = bản sắc"]
    GEAR["Trang bị 8 ô · Rune · Talent · Awaken"]
    SYN["Synergy đội-5 · race/class/coalition"]
  end

  subgraph CORE["♻️ VÒNG LẶP LÕI"]
    RES["Tài nguyên"]
    UPG["Nâng cấp · hero/đồ/building/Lord"]
    POWER["Mạnh hơn"]
    ZONE["Mở Region / Difficulty mới"]
    RES --> UPG --> POWER --> ZONE
  end

  subgraph ENDGAME["⚔️ NỘI DUNG SÂU"]
    STORY["Story Campaign + Story Boss"]
    WB["World Boss (tuần)"]
    ARENA["Đấu Trường (bot → PvP)"]
    RAID["Raid Dungeon"]
    SEASON["Season/Event · Abyss"]
  end

  LORD --> TOWN
  TOWN -->|hero tự trị ra trận| GATE
  GATE -->|teleport| FIELD
  FIELD -->|HP thấp / túi đầy / KO| GATE
  GATE --> TOWN
  ALTAR -->|summon| HERO
  HERO --> BATTLE
  LOOT --> RES
  ZONE --> FIELD
  POWER --> ENDGAME
  ENDGAME -->|thưởng đậm + shard| RES
```

---

## 2) Hành trình người chơi (A → F)

```mermaid
flowchart LR
  A["A · Màn Mở (0–15')<br/>tạo Lord · hero đầu · trận đầu · gacha đầu"]
  B["B · Tân Thủ (Lord 1–15)<br/>progressive disclosure: mỗi bước mở 1 hệ"]
  C["C · Tốt Nghiệp<br/>Lord 15 + đủ hệ lõi ⇒ bỏ chuỗi tân thủ"]
  D["D · Vận Hành<br/>nhịp ngày/tuần: daily · boss · minigame"]
  E["E · Chiều Sâu<br/>hoàn thiện build · leo mode khó · sưu tập hero"]
  F["F · Hậu Game<br/>Endless · Ancient/Season Boss · tối ưu meta"]

  A --> B --> C --> D --> E --> F
  F -. thế giới vẫn sống, xoay Season .-> D
```

---

## 3) Ba track tiến trình song song (luôn có việc)

```mermaid
flowchart TB
  ROOT["Người chơi luôn có 3 hướng tiến"]
  ROOT --> T1["① Bề rộng roster<br/>gacha · shard · codex"]
  ROOT --> T2["② Chiều sâu build<br/>trang bị · rune · talent · awaken · synergy"]
  ROOT --> T3["③ Thành & Lãnh Chúa<br/>building · Lord Level · Đặc Ân"]
  T1 --> FLEX["Track này nghẽn → chuyển track khác<br/>⇒ không bao giờ hết việc"]
  T2 --> FLEX
  T3 --> FLEX
```

---

**Ghi chú:**
- Người chơi **quản lý**, hero **tự trị** (Utility AI) — xem, không điều khiển trực tiếp.
- Combat qua **Battle Engine tất định** (seeded) dùng chung cho Bãi Săn / Stage / Boss / Arena / Raid.
- Cân bằng: *Strategy > Power* — không đội hình bất bại; content (element/modifier/objective) chọn winner theo trận (xem [TEAMBUILD.md](TEAMBUILD.md)).
