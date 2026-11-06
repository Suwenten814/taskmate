# 📚 TaskMate — Aplikasi Pengelola Tugas Mahasiswa

TaskMate adalah aplikasi mobile berbasis Flutter yang dirancang untuk membantu mahasiswa mengelola tugas kuliah, memantau tenggat waktu, dan melihat progres penyelesaian tugas.

Aplikasi ini dikembangkan sebagai proyek Ujian Tengah Semester (UTS).

## ✨ Fitur Utama

- **Dashboard:** Menampilkan ringkasan semua tugas, tugas yang belum selesai, dan tugas yang sudah selesai.
- **Manajemen Tugas:** Menambahkan, melihat, mengedit, dan menghapus tugas.
- **Checklist Tugas:** Mengubah status tugas menjadi selesai atau belum selesai.
- **Tanggal Tenggat:** Memilih tanggal tenggat tugas menggunakan date picker.
- **Detail Tugas:** Melihat informasi tugas secara lebih lengkap.
- **Progres Tugas:** Menampilkan persentase penyelesaian tugas.
- **REST API:** Mengambil data tugas dari API dan menampilkan loading, error, empty state, serta fitur retry.
- **Supabase:** Menyimpan dan mengelola data tugas menggunakan operasi CRUD.
- **Validasi Form:** Memastikan kolom wajib diisi sebelum tugas disimpan.
- **Responsive UI:** Menyesuaikan tampilan berdasarkan lebar layar.
- **Feedback Pengguna:** Menampilkan SnackBar untuk hasil operasi.

## 🛠️ Teknologi

- Flutter
- Dart
- Provider
- ChangeNotifier
- REST API
- Supabase
- JSON

## 🏗️ Arsitektur Aplikasi

TaskMate menggunakan pemisahan tanggung jawab agar kode lebih mudah dikelola.

Alur pengambilan dan pengelolaan data:

```text
UI / Screen
    ↓
Provider
    ↓
Repository (untuk REST API)
    ↓
Service
    ↓
REST API / Supabase