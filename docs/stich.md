# Google Stitch UI/UX Redesign Prompt

Salin dan gunakan prompt di bawah ini pada Google Stitch untuk menghasilkan desain antarmuka (UI) yang modern, premium, dan bertema gelap (Dark Modern).

---

## Prompt untuk Google Stitch

Desain sebuah antarmuka web/aplikasi dashboard mahasiswa bernama "DeadlineHUB" dengan tema gelap modern (Dark Modern Theme). Antarmuka harus terlihat premium, bersih, dan menggunakan elemen visual seperti glassmorphic panels, glowing border accents, dan tipografi modern yang mudah dibaca.

### 1. Sistem Desain dan Estetika
*   **Warna Utama:** Latar belakang gelap pekat (seperti `#0F1115` atau `#1E222A`) dengan panel semi-transparan (`#282C34` dengan opasitas rendah) yang memberikan efek kaca/frosted glass (glassmorphism).
*   **Warna Aksen:** Gunakan warna neon yang elegan dan tidak berlebihan:
    *   Biru Cyan/Neon Blue (`#61AFEF`) untuk navigasi aktif dan fokus utama.
    *   Hijau Neon Muted (`#98C379`) untuk indikator selesai/success.
    *   Merah Coral (`#E06C75`) untuk penanda tugas darurat/urgency.
    *   Ungu Violet (`#C678DD`) untuk elemen pendukung kecerdasan buatan (AI).
*   **Tipografi:** Gunakan font sans-serif modern (seperti Inter atau Outfit) dengan kontras hierarki teks yang tajam antara judul dan deskripsi.
*   **Batas & Bayangan:** Gunakan border tipis 1px berwarna abu-abu gelap transparan (`rgba(255, 255, 255, 0.08)`) dengan bayangan halus (soft drop shadows).

### 2. Tata Letak Dashboard (Layout)
Gunakan tata letak 3-panel atau grid responsif yang efisien untuk meminimalkan scrolling:
*   **Panel Navigasi Kiri (Sidebar):**
    *   Menu navigasi vertikal yang ringkas (Dashboard, Calendar, Classroom, Emails, Drive, Settings).
    *   Status koneksi akun Google & API Key Gemini dengan indikator dot menyala (glowing status indicator).
*   **Area Konten Utama (Center):**
    *   **Weekly Planner (Kalender):** Tampilan jadwal mingguan minimalis berformat list atau grid. Setiap kartu jadwal memiliki tombol teks "Ubah" (warna biru) dan "Hapus" (warna merah outline) di bagian kanan kartu.
    *   **Classroom Deadlines:** Daftar tugas kuliah yang diurutkan secara vertikal. Setiap kartu tugas memiliki badge kategori kuliah, status urgensi jika deadline kurang dari 48 jam, dan dua tombol teks di sebelah kanan: "Selesai" (warna hijau) dan "Buka" (warna biru).
*   **Panel Samping Kanan (Sidebar Kanan/Drawer):**
    *   **AI Chat Assistant:** Panel chat interaktif untuk mengobrol dengan asisten AI. Chat bubble berwarna abu-abu gelap untuk AI, dan biru transparan untuk pengguna. Mendukung tampilan Markdown (bold, italic, list, dan blok kode dengan latar belakang gelap).
    *   **AI Schedule Creator:** Kolom input prompt teks besar untuk memasukkan instruksi belajar alami, dengan tombol draf jadwal di bawahnya yang bisa diedit sebelum disinkronkan ke kalender utama.

### 3. Komponen Khusus & Mikro-Interaksi
*   **AI Email Summary Card:** Dialog popup minimalis yang muncul ketika pengguna ingin merangkum email. Di dalamnya terdapat spinner loading melingkar saat memuat data, serta teks hasil rangkuman AI yang rapi dan mudah dibaca dengan tombol "Tutup" di bagian bawah.
*   **Quick Action Cards:** Tombol cepat (chips) di bawah kolom input chat asisten AI seperti "Apa deadline saya?" atau "Jadwalkan belajar besok".
*   **Hover & Active States:** Seluruh tombol teks, dropdown, dan kartu interaktif harus memiliki transisi warna/opasitas halus saat disorot (hover) untuk meningkatkan pengalaman interaksi pengguna.
