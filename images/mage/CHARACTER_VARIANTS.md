# Mage Character Variants — Generation Spec

Dựa trên 3 reference sheet có sẵn (`mage-01.png` = Alden, `mage-02.png` = Brock,
`mage-03.png` = Caine). Tài liệu này định nghĩa **30 nhân vật Mage mới** (04–33),
dùng chung mọi thứ với 3 nhân vật gốc, chỉ khác **Tên / Kiểu tóc / Dáng người / Khuôn mặt**.

Đưa nguyên phần "Prompt" của từng nhân vật vào công cụ sinh ảnh (kèm theo 1-3 ảnh
`mage-01/02/03.png` làm reference ảnh phong cách) để giữ đúng art style.

---

## Giữ nguyên (không đổi so với bản gốc)

- **Class:** Mage
- **Style:** Pixel Art, top-down/side hybrid character sheet, pixel perfect, no anti-alias
- **Height range:** ~155–181cm (biến thiên nhẹ theo Build, không phải yếu tố chính)
- **Trang phục:** ở trần, quần short xám, giày/ủng cam-nâu, vòng ma pháp tím dưới chân khi cast
- **Palette:** tông da ấm + trang phục xám/nâu trung tính + hiệu ứng phép thuật màu tím (arcane)
- **Bố cục thẻ:** số thứ tự + tên/class/height/style ở góc trái trên, bảng palette bên dưới,
  vòng phép dưới chân nhân vật preview
- **Animation grid** (giống hệt 3 sheet gốc):
  - Basic Actions: Idle, Walk, Run, Dash, Backstep, Jump, Fall, Land
  - Combat Actions: Attack 1–3, Cast Start/Loop/End, Damage (Hit), Knockback, Get Up
  - Spells – Offensive: Fireball, Ice Spike, Lightning, Arcane Missile, Arcane Explosion, Meteor
  - Spells – Support/Utility: Magic Shield, Teleport, Haste, Mana Regen, Magic Barrier, Invisibility, Dispel
  - Emotes: Think, Confused, Exclamation, Casting (Idle), Read Book, Victory, Cheer, Sit, Sleep
  - Damage & Death: Hit, Heavy Hit, Knockdown, Get Up, Die, Dead
  - Turn Around

## Prompt template

```
Pixel art character reference sheet, [NAME], Class: Mage, Height: [HEIGHT]cm, Style: Pixel Art.
Hair: [HAIR]. Build: [BUILD]. Face: [FACE].
Bare-chested young apprentice mage, grey shorts, brown-orange boots, warm skin tone,
purple arcane magic aura and spell effects, dark navy background with palette swatch box
top-left, full animation grid identical layout to reference (Idle/Walk/Run/Dash/Backstep/
Jump/Fall/Land, Attack1-3, Cast Start/Loop/End, Damage/Knockback/Get Up, offensive spells
Fireball/Ice Spike/Lightning/Arcane Missile/Arcane Explosion/Meteor, support spells Magic
Shield/Teleport/Haste/Mana Regen/Magic Barrier/Invisibility/Dispel, emotes Think/Confused/
Exclamation/Casting Idle/Read Book/Victory/Cheer/Sit/Sleep, damage&death Hit/Heavy Hit/
Knockdown/Get Up/Die/Dead, turn-around row), pixel perfect, no anti-alias, no blur,
consistent with mage-01/mage-02/mage-03 reference style.
```

---

## 30 Nhân vật

| # | Tên | Height | Tóc | Dáng người | Khuôn mặt |
|---|-----|--------|-----|------------|-----------|
| 04 | Dorian | 172cm | Bạc, spiky ngắn | Gầy, dẻo dai | Mặt góc cạnh, mắt tím hẹp, cười nhếch mép |
| 05 | Elric | 178cm | Đỏ lửa, rối bù | Cao, lêu nghêu | Tàn nhang, mắt xanh lá sáng, cười tự tin |
| 06 | Finn | 160cm | Vàng cát, bowl cut | Thấp, chắc nịch | Mặt tròn trẻ con, mắt nâu to, cười hở răng sún |
| 07 | Garron | 176cm | Đen tuyền, đuôi ngựa dài | Vai rộng, vạm vỡ | Gò má cao, chân mày nhíu, sẹo mờ trên mắt trái |
| 08 | Hale | 168cm | Xám tro, undercut một bên | Mảnh khảnh, trung bình | Nét mềm, mắt lim dim buồn ngủ |
| 09 | Ivor | 158cm | Nâu sẫm, xoăn afro | Nhỏ nhắn | Má lúm, mắt to tò mò |
| 10 | Jasper | 174cm | Cam đồng, mohawk gai | Thể thao, săn chắc | Quai hàm sắc, ánh mắt quyết tâm, râu lún phún |
| 11 | Kael | 180cm | Vàng bạch kim, chải ngược | Cao, mảnh dẻ | Cằm thon, mắt hạnh nhân điềm tĩnh |
| 12 | Leif | 166cm | Nâu hạt dẻ, wolf cut | Trung bình, hơi khom | Tàn nhang mũi, cười hở răng sún |
| 13 | Milo | 155cm | Nâu cát, tóc xoáy rối | Thấp, mũm mĩm | Má phính, mắt nâu hạt dẻ to tròn |
| 14 | Nash | 170cm | Đen than, cắt trọc ngắn | Cơ bắp gọn, chắc | Chân mày rậm, ánh nhìn sắc, sẹo nhỏ trên cằm |
| 15 | Oren | 175cm | Vàng kim, mái rèm | Gầy, thanh mảnh | Nét thanh tú, mắt xanh nhạt, cười nhẹ |
| 16 | Percy | 163cm | Hạt dẻ đỏ, gợn sóng ngang vai | Mảnh, vai hẹp | Tàn nhang, ánh mắt rụt rè cúi xuống |
| 17 | Quill | 179cm | Tím than, layer xù | Cao, gầy lỏng khỏng | Mắt lệch màu (1 xanh 1 hổ phách), cười nhếch |
| 18 | Rhys | 169cm | Vàng đất, mái hất chéo | Trung bình, dẻo dai | Gò má sắc, ánh nhìn tập trung |
| 19 | Silas | 165cm | Bạc trắng, búi cao 2 bên cạo | Chắc nịch, thấp | Mặt phong trần, sẹo một bên chân mày |
| 20 | Tobin | 157cm | Đỏ gạch, tóc bờm ngắn | Thấp, chắc nịch | Mặt tròn, tàn nhang, cười toe toét |
| 21 | Ulric | 177cm | Xám thép, dreadlock buộc sau | To, vạm vỡ | Mắt sâu, biểu cảm nghiêm nghị |
| 22 | Varek | 181cm | Xanh đen, chải mượt ra sau | Cao, gầy | Quai hàm góc cạnh, ánh mắt lạnh sắc |
| 23 | Wren | 159cm | Vàng mật ong, layer lông vũ | Nhỏ nhắn, mảnh mai | Mắt tròn dịu dàng, nụ cười hiền |
| 24 | Xander | 173cm | Nâu đồng, mái so le | Thể thao | Cười tự tin, khoen mũi nhỏ |
| 25 | Yorick | 167cm | Trắng nhạt, tóc dài thẳng | Gầy yếu, mong manh | Má hóp, mắt tím mệt mỏi |
| 26 | Zane | 175cm | Cam lửa, mohawk fade | Vạm vỡ, to con | Cười toe rạng rỡ, tàn nhang như vết bỏng |
| 27 | Corvin | 178cm | Đen quạ, xù gai loạn | Cao, gầy dài | Chân mày sắc, mắt đen xoáy sâu |
| 28 | Dax | 162cm | Vàng cháy nắng, buzz fade | Thấp, chắc nịch | Má rám nắng, mắt nheo vui vẻ |
| 29 | Emrys | 171cm | Bạc tím nhạt, gợn sóng dài vừa | Mảnh, dáng thanh thoát | Nét thanh lịch, mắt tím điềm đạm |
| 30 | Fenn | 158cm | Xanh rêu nhuộm, tóc ngắn rối | Thấp, dẻo dai | Tàn nhang, cười tinh nghịch |
| 31 | Gideon | 180cm | Nâu sẫm, pompadour chải bóng | Cao, vai rộng | Quai hàm khỏe, ánh mắt tự tin |
| 32 | Holt | 164cm | Xám xanh phối sương, crew cut gai | Chắc nịch, thấp | Má tròn, mắt sáng tò mò |
| 33 | Ian | 170cm | Nâu hạt dẻ ấm, xoăn mì tôm | Trung bình | Mặt tròn mềm, cười lúm đồng tiền thân thiện |

---

## Prompt đầy đủ cho từng nhân vật

### 04 — Dorian
```
Pixel art character reference sheet, Dorian, Class: Mage, Height: 172cm, Style: Pixel Art.
Hair: silver, short spiky. Build: lean, wiry frame. Face: sharp angular face, narrow violet eyes, faint smirk.
Bare-chested young apprentice mage, grey shorts, brown-orange boots, warm skin tone, purple arcane
magic aura and spell effects, dark navy background with palette swatch box top-left, full animation
grid identical layout to reference (Idle/Walk/Run/Dash/Backstep/Jump/Fall/Land, Attack1-3, Cast
Start/Loop/End, Damage/Knockback/Get Up, offensive spells Fireball/Ice Spike/Lightning/Arcane
Missile/Arcane Explosion/Meteor, support spells Magic Shield/Teleport/Haste/Mana Regen/Magic
Barrier/Invisibility/Dispel, emotes Think/Confused/Exclamation/Casting Idle/Read Book/Victory/Cheer/
Sit/Sleep, damage&death Hit/Heavy Hit/Knockdown/Get Up/Die/Dead, turn-around row), pixel perfect,
no anti-alias, no blur, consistent with mage-01/mage-02/mage-03 reference style.
```

### 05 — Elric
```
Hair: fiery red, messy shag. Build: tall and lanky. Face: freckled cheeks, bright green eyes, confident grin.
Height: 178cm. (ghép vào template chung ở trên)
```

### 06 — Finn
```
Hair: sandy blonde, bowl cut. Build: short and stocky. Face: round baby face, big brown eyes, cheerful gap-tooth smile.
Height: 160cm.
```

### 07 — Garron
```
Hair: jet black, long ponytail. Build: broad-shouldered, sturdy. Face: high cheekbones, stern brow, thin scar over left eye.
Height: 176cm.
```

### 08 — Hale
```
Hair: ash-grey undercut with one side shaved. Build: slim, average height. Face: soft features, sleepy half-lidded eyes.
Height: 168cm.
```

### 09 — Ivor
```
Hair: dark brown curly afro. Build: petite, small frame. Face: dimpled cheeks, wide curious eyes.
Height: 158cm.
```

### 10 — Jasper
```
Hair: copper-orange spiked mohawk. Build: athletic, toned. Face: sharp jaw, determined glare, faint stubble shadow.
Height: 174cm.
```

### 11 — Kael
```
Hair: platinum blonde, slicked back. Build: tall, slender. Face: narrow chin, calm almond eyes, composed expression.
Height: 180cm.
```

### 12 — Leif
```
Hair: chestnut brown wolf cut. Build: average build, slightly hunched posture. Face: freckles across nose, gap-tooth grin.
Height: 166cm.
```

### 13 — Milo
```
Hair: sandy brown messy cowlick. Build: short, pudgy/round build. Face: chubby cheeks, big round hazel eyes.
Height: 155cm.
```

### 14 — Nash
```
Hair: charcoal black buzzcut. Build: muscular for his age, compact. Face: thick eyebrows, sharp glare, small scar on chin.
Height: 170cm.
```

### 15 — Oren
```
Hair: golden blonde curtain fringe. Build: lean and willowy. Face: delicate features, pale blue eyes, faint smile.
Height: 175cm.
```

### 16 — Percy
```
Hair: auburn, wavy shoulder-length. Build: slim, narrow shoulders. Face: freckled, shy downward gaze.
Height: 163cm.
```

### 17 — Quill
```
Hair: deep violet-dyed shaggy layers. Build: tall and gangly. Face: heterochromia (one blue, one amber eye), smirk.
Height: 179cm.
```

### 18 — Rhys
```
Hair: dirty blonde side-swept fringe. Build: average height, wiry. Face: sharp cheekbones, focused stare.
Height: 169cm.
```

### 19 — Silas
```
Hair: silver-white top bun with shaved sides. Build: stocky, compact. Face: weathered young face, one eyebrow scar.
Height: 165cm.
```

### 20 — Tobin
```
Hair: rust-red short spiky tufts. Build: short and stocky. Face: round face, freckles, wide grin.
Height: 157cm.
```

### 21 — Ulric
```
Hair: steel-grey dreadlocks tied back. Build: broad, sturdy build. Face: deep-set eyes, serious stern expression.
Height: 177cm.
```

### 22 — Varek
```
Hair: midnight blue-black slicked back. Build: tall, lean. Face: angular jaw, cold intense gaze.
Height: 181cm.
```

### 23 — Wren
```
Hair: honey-blonde feathered layers. Build: petite, slender. Face: soft round eyes, gentle smile.
Height: 159cm.
```

### 24 — Xander
```
Hair: bronze-brown choppy bangs. Build: athletic build. Face: confident smirk, small nose stud.
Height: 173cm.
```

### 25 — Yorick
```
Hair: pale white, long straight hair. Build: thin, frail frame. Face: hollow cheeks, tired violet eyes.
Height: 167cm.
```

### 26 — Zane
```
Hair: ember-orange mohawk fade. Build: muscular, broad. Face: bold grin, faint burn-mark freckle pattern.
Height: 175cm.
```

### 27 — Corvin
```
Hair: raven-black wild spikes. Build: tall and rangy. Face: sharp brow, piercing dark eyes.
Height: 178cm.
```

### 28 — Dax
```
Hair: sun-bleached blonde buzz fade. Build: short, stocky. Face: sunburnt cheeks, squinting cheerful eyes.
Height: 162cm.
```

### 29 — Emrys
```
Hair: silver-lilac wavy medium length. Build: slim, graceful posture. Face: elegant features, calm violet eyes.
Height: 171cm.
```

### 30 — Fenn
```
Hair: moss-green dyed messy crop. Build: short, wiry. Face: freckled, mischievous smirk.
Height: 158cm.
```

### 31 — Gideon
```
Hair: deep brown slicked pompadour. Build: tall, broad-shouldered. Face: strong jaw, confident stare.
Height: 180cm.
```

### 32 — Holt
```
Hair: frosted grey-blue spiky crew cut. Build: stocky, compact. Face: round cheeks, bright curious eyes.
Height: 164cm.
```

### 33 — Ian
```
Hair: warm chestnut curly mop top. Build: average build. Face: soft round face, friendly dimpled smile.
Height: 170cm.
```

> Ghi chú: từ #05 trở đi chỉ liệt kê phần biến đổi (Hair/Build/Face/Height/Name) —
> ghép vào đúng vị trí trong "Prompt template" ở trên để có prompt đầy đủ như #04.
