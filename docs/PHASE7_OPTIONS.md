# Phase 7 — Catalog Quyết Định (cửa trước)

> Bảng chọn cho cụm **Lãnh Chúa · Tân thủ · Quest · Minigame · Formation-5+Loadout · Raid**.
> Mỗi quyết định: options + ưu/nhược + **★ = tôi đề xuất**. Điền **"→ Chọn: ___"** hoặc sửa tuỳ ý.
> Chốt xong tôi gấp kết quả vào `PHASE7.md` (spec tới từng unit) rồi mới code.

## Đã LOCK (không hỏi lại)
Team formation = **5** · Loadout = **overlap preset + deploy-lock** · **no-permadeath** (KO+injury) · reward qua **grant_reward** · **new_account()** riêng (giữ new_game cho test) · **save v8** một lần · offline reward ≤80%.

## Cách dùng nhanh
Nếu tin đề xuất → ghi **"Default hết trừ …"** ở cuối (§8) và chỉ liệt kê chỗ muốn đổi. Nếu muốn cân nhắc từng cái → điền theo từng mục.

---

# §1 — Lãnh Chúa (S0)

### 1.1 Đặc Ân (Lord Perks) — loại buff
| # | Option | Ưu | Nhược |
|---|---|---|---|
| ★A | Buff **tiện ích** (energy cap, %vàng loot, +slot expedition/quest, tốc hồi inn) | No-P2W tuyệt đối, an toàn cân bằng | Cảm giác "lực" nhẹ |
| B | Không perk — Lord chỉ là avatar + cổng mở khoá | Đơn giản nhất | Lên cấp Lord kém phần thưởng |
| C | Perk QoL mạnh hơn (auto-repeat, offline cap cao hơn, giảm phí) | Cảm giác tiến bộ rõ | Dễ trượt thành pay-time-save |

→ Chọn: ___

### 1.2 Lord Level lên bằng gì
| # | Option | Ưu | Nhược |
|---|---|---|---|
| ★A | **Quest + Story** (không từ combat trực tiếp) | Thưởng "chơi đủ rộng", chống cày 1 chỗ | Cần quest sống trước |
| B | Mọi hành động (đánh/loot/craft đều cho Lord XP) | Luôn tiến bộ | Khó tune, dễ lạm phát cấp |
| C | Chỉ story milestone | Gọn | Tiến chậm, phụ thuộc story |

→ Chọn: ___

### 1.3 Mức tuỳ biến khi tạo Lãnh Chúa
| # | Option | Ưu | Nhược |
|---|---|---|---|
| ★A | Tên + chọn **chân dung/huy hiệu từ set** (placeholder art) | MVP đủ bản sắc, art sau | Chưa sâu |
| B | Chỉ tên | Nhanh nhất | Nhạt |
| C | Tuỳ biến sâu (màu/phụ kiện) | Cá tính cao | Tốn art, hoãn hợp lý |

→ Chọn: ___

---

# §2 — Tân Thủ (S3)

### 2.1 Ngưỡng tốt nghiệp
| # | Option | Ưu | Nhược |
|---|---|---|---|
| B | Lord 10 + đủ feature | Thả tự do sớm | Có thể chưa quen hết hệ |
| ★A | **Lord 15 + đủ 13 feature lõi** | Cân giữa dạy đủ & không lê thê (~1 tuần) | — |
| C | Lord 20 + đủ feature | Dạy rất kỹ | Dài, dễ chán |

→ Chọn: ___

### 2.2 Kiểu dẫn dắt
| # | Option | Ưu | Nhược |
|---|---|---|---|
| ★A | **Checklist mềm** (gợi ý, không chặn thao tác khác) | Tôn trọng người chơi, ít bực | Vài người bỏ qua bước |
| B | Hard-gate từng bước (chặn đến khi làm xong) | Không ai lạc | Gò bó, mobile hay bị "ép" |
| C | Hybrid (gate 3-4 bước lõi đầu, còn lại mềm) | Chắc phần cốt, thoáng phần sau | Phức tạp hơn |

→ Chọn: ___

### 2.3 Bỏ qua tân thủ (returning/vượt cấp)
| # | Option | Ưu | Nhược |
|---|---|---|---|
| ★A | `skip_completed` tự bỏ bước đã thoả (không bắt làm lại) | Mượt cho save cũ/event | — |
| B | + Nút "Skip toàn bộ" (xác nhận) | Veteran vui | Người mới lỡ tay mất dạy |
| C | Không skip | Đơn giản | Bực với người đã biết |

→ Chọn: ___

---

# §3 — Hệ Nhiệm Vụ (S2)

### 3.1 Mô hình thưởng
| # | Option | Ưu | Nhược |
|---|---|---|---|
| ★A | **Điểm-HĐ → Rương** (làm đủ nhóm việc mới mở rương) | Đẩy người chơi chạm nhiều hệ, chuẩn EHT/battle-pass | Cần track điểm |
| B | Mỗi quest thưởng rời | Đơn giản, tức thì | Người chơi chỉ làm quest dễ |
| C | Cả hai (rời + rương bonus) | Linh hoạt | Nhiều UI, dễ rối |

→ Chọn: ___

### 3.2 Số nhiệm vụ ngày
| # | Option | Ưu | Nhược |
|---|---|---|---|
| 4 | Ít | Nhẹ, nhanh | Ít lý do chạm hệ |
| ★6 | **Vừa** | Đủ phủ các hệ chính, ~10-15' | — |
| 8 | Nhiều | Giữ chân lâu | Dễ thành "job" |

→ Chọn: ___

### 3.3 Mốc reset (QUAN TRỌNG kỹ thuật)
> Lưu ý: `TimeService.game_day()` = **ngày mô phỏng nén (1 giờ thực = 1 "ngày" game)** cho sản xuất kitchen — **KHÔNG** dùng cho reset quest. Quest phải theo **ngày lịch thực** (`now_unix` → real date).
| # | Option | Ưu | Nhược |
|---|---|---|---|
| ★A | **Giờ cố định theo giờ thực** (vd 04:00 local) | Chuẩn, người chơi quen nhịp | — |
| B | Rolling 24h từ lần nhận | Công bằng múi giờ | Nhịp trôi, khó tạo thói quen |
| C | Server-fixed (khi online) | Đồng bộ leaderboard | Offline chưa cần |

→ Chọn: ___

### 3.4 Quest weekly có "cổng" không (energy/attempt)
| # | Option | Ưu | Nhược |
|---|---|---|---|
| ★A | Weekly là mục tiêu tích luỹ (không gate riêng) | Tự nhiên, không phạt | — |
| B | Vài weekly gắn mode giới-hạn-lượt (raid/boss) | Tạo sự kiện đáng chờ | Có thể miss nếu bận |

→ Chọn: ___

---

# §4 — Minigame (S5)

### 4.1 Bộ MVP
| # | Option | Ưu | Nhược |
|---|---|---|---|
| ★A | **Câu Cá + Rèn Nhịp** (2 game) | Đủ đổi nhịp, 2 loại cơ chế | 2 UI |
| B | Chỉ Câu Cá | Ít việc nhất | Đơn điệu |
| C | 3+ (thêm Xúc Xắc/Đào kho báu) | Đa dạng | Tốn công, hoãn được |

→ Chọn: ___

### 4.2 Giới hạn thưởng
| # | Option | Ưu | Nhược |
|---|---|---|---|
| ★A | **Trần lượt/ngày cứng** (vd 5) | Là gia vị, không phá kinh tế | Người chơi hết thì tiếc |
| B | Tốn energy | Dùng chung tài nguyên | Cạnh tranh energy với expedition |
| C | Không giới hạn | Vui thả ga | Dễ farm lệch, phá economy |

→ Chọn: ___

### 4.3 Điểm vào
| # | Option | Ưu | Nhược |
|---|---|---|---|
| ★A | Chạm **building** trong thành (Bến/Xưởng Rèn) | Gắn thành sống, immersive | Cần building tap |
| B | Nút trong menu Minigame | Dễ tìm | Kém immersive |

→ Chọn: ___

---

# §5 — Formation-5 + Loadout (SF)

### 5.1 Số preset đội tối đa
| # | Option | Ưu | Nhược |
|---|---|---|---|
| 5 | Ít | Gọn | Chật với nhiều mode |
| ★10 | **Vừa** | Đủ cho farm/arena/raid/boss + thử nghiệm | — |
| ∞ | Không giới hạn (soft) | Tự do | UI list dài, ít ai cần |

→ Chọn: ___

### 5.2 Arena defense có khoá hero?
| # | Option | Ưu | Nhược |
|---|---|---|---|
| ★A | **KHÔNG khoá** (defense = snapshot đông cứng) | Đội thủ trùng đội công thoải mái, chuẩn genre | — |
| B | Có khoá | "Thực" hơn | Bực: phải tách đội thủ riêng |

→ Chọn: ___

### 5.3 Slot thứ 4-5: cho sẵn hay mở khoá dần
| # | Option | Ưu | Nhược |
|---|---|---|---|
| ★A | **Mở khoá dần 3→4→5** qua tân thủ (slot 5 ~Lord 8-10) | Cây kẹo onboarding mạnh, dạy formation lớn dần | Người mới đội nhỏ lúc đầu |
| B | Đủ 5 từ đầu | Đơn giản, đủ synergy ngay | Mất 1 mốc phần thưởng |

→ Chọn: ___

### 5.4 Độ phức tạp Formation buff
| # | Option | Ưu | Nhược |
|---|---|---|---|
| ★A | **Front/Back buff đơn giản** (front +def, back +atk/tốc) — như hiện tại | Dễ hiểu, dễ tune, mobile-readable | Ít chiều sâu vị trí |
| B | Thêm cột/ô-vị-trí (target-bias theo slot) | Chiều sâu chiến thuật | Phức tạp, khó đọc màn dọc |

→ Chọn: ___

---

# §6 — Raid Dungeon (S6)

### 6.1 Assist bot (đồng đội offline) lấy từ đâu
| # | Option | Ưu | Nhược |
|---|---|---|---|
| ★A | **arena_bot_pool** (đã có sẵn) | Ship nhanh, tái dùng data | Bot generic |
| B | Mượn từ roster của chính mình (hero rảnh) | Dùng hero mình yêu thích | Xung đột deploy-lock |
| C | Hero NPC riêng cho raid (có lore) | Bản sắc | Tốn data/art |

→ Chọn: ___

### 6.2 Quota
| # | Option | Ưu | Nhược |
|---|---|---|---|
| ★A | **Tuần 3 lượt** | Đáng chờ, chống spam | Miss nếu bận |
| B | Ngày (vé) | Nhịp đều | Áp lực daily |
| C | Vé mua thêm (gem) | Nguồn sink | Cẩn thận P2W-ish |

→ Chọn: ___

### 6.3 HP mang sang boss kế (gauntlet)?
| # | Option | Ưu | Nhược |
|---|---|---|---|
| ★A | **Mang HP sang** (attrition) | Đúng chất "raid", chiến thuật đội bền | Khó hơn, cần sustain |
| B | Reset HP mỗi boss | Dễ tiếp cận | Giống stage nối tiếp, kém đặc trưng |
| C | Hồi 1 phần giữa boss | Cân giữa | Thêm 1 tham số tune |

→ Chọn: ___

### 6.4 Số boss MVP
| # | Option | Ưu | Nhược |
|---|---|---|---|
| ★A | **2 boss** (forest_guardian + abyss_dragon có sẵn) | Ship ngay, đủ chứng minh | Ngắn |
| B | 3 boss | "Raid" hơn | Cần thêm boss data |

→ Chọn: ___

---

# §7 — Thứ tự build & Phạm vi MVP

### 7.1 Thứ tự
★ Đề xuất: **S0 → SF → S1 → S2 → S3 → S4 → S5 → S6** (nền Lord + đội hình trước, rồi thoại → quest → tân thủ → màn mở → minigame → raid).
→ Sửa: ___

### 7.2 Phạm vi MVP cửa-trước — nên cắt gì ra "đợt 2"?
| # | Option | Gồm | Ghi chú |
|---|---|---|---|
| ★A | **MVP gọn** = S0+SF+S1+S2+S3+S4 (Lord, đội hình, thoại, quest, tân thủ, màn mở). **Minigame(S5)+Raid(S6) → đợt 2** | Trọn "cửa trước" người chơi mới cần | Ship nhanh, raid vốn là mid-game |
| B | MVP đầy đủ = tất cả S0–S6 | Trọn cụm | Lâu hơn |
| C | MVP tối thiểu = S0+SF+S1+S3+S4 (bỏ cả quest S2 đợt 1) | Chỉ luồng mở màn | Quest là trụ giữ-chân, không nên bỏ lâu |

→ Chọn: ___

---

# §8 — Chốt nhanh (Default Bundle)

Nếu đồng ý toàn bộ ★, chỉ cần ghi: **"Default hết"** + liệt kê ngoại lệ.

Tóm tắt bundle ★:
- Lord: perk **tiện-ích** · lên cấp bằng **quest+story** · tạo Lord **tên+chân dung/huy hiệu set**.
- Tân thủ: tốt nghiệp **Lord15+13 feature** · **checklist mềm** · **skip_completed**.
- Quest: **điểm-HĐ→rương** · **6 daily** · reset **giờ thực cố định** · weekly **tích luỹ**.
- Minigame: **Câu Cá + Rèn Nhịp** · **trần-ngày** · vào qua **building**.
- Formation: **10 preset** · defense **không khoá** · slot **mở khoá 3→4→5** · buff **front/back đơn giản**.
- Raid: bot **arena_pool** · **tuần 3 lượt** · **mang HP** · **2 boss**.
- Build: **S0→SF→S1→S2→S3→S4→S5→S6**, MVP = **đợt 1 gọn (S0-S4)**, minigame+raid đợt 2.

→ Quyết định của bạn: ___
