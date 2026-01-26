#  Microservices Learning Project - CI/CD

Proyek belajar CI/CD dengan Node.js (Express) dan React menggunakan Docker & Docker Compose.

##  Struktur Folder

```
c:\IBM\nyoba
├── backend/
│   ├── server.js              # Express server utama
│   ├── package.json           # Dependencies backend
│   ├── Dockerfile             # Docker image untuk backend
│   └── .dockerignore          # File yang diabaikan saat build
├── frontend/
│   ├── App.js                 # React component utama
│   ├── App.css                # Styling
│   ├── index.js               # Entry point
│   ├── index.css              # Global styles
│   ├── package.json           # Dependencies frontend
│   ├── Dockerfile             # Docker image untuk frontend
│   ├── nginx.conf             # Konfigurasi Nginx
│   ├── public/
│   │   └── index.html         # HTML template
│   └── .dockerignore          # File yang diabaikan saat build
└── docker-compose.yml         # Konfigurasi untuk menjalankan kedua service
```

## Cara Menjalankan Menggunakan Docker Compose

### Prasyarat
- **Docker Desktop** terinstall (https://www.docker.com/products/docker-desktop)
- **Terminal/PowerShell** 

### Langkah-Langkah:

#### 1. **Buka Terminal/PowerShell dan navigasi ke folder project**
```bash
cd c:\IBM\nyoba
```

#### 2. **Build images dan jalankan containers**
```bash
docker-compose up --build
```

Output yang akan muncul:
```
[+] Building 2.3s (20/20) FINISHED
[+] Running 2/2
  ✓ Container microservices-backend running
  ✓ Container microservices-frontend running
```

#### 3. **Akses aplikasi di browser**
- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:5000/api/data
- **Backend Health Check**: http://localhost:5000/health

#### 4. **Melihat logs dari containers**
Untuk melihat semua logs:
```bash
docker-compose logs -f
```

Untuk melihat logs backend saja:
```bash
docker-compose logs -f backend
```

Untuk melihat logs frontend saja:
```bash
docker-compose logs -f frontend
```

#### 5. **Menghentikan services**
Tekan `CTRL + C` di terminal, atau jalankan:
```bash
docker-compose down
```

Untuk menghapus semua containers dan volumes:
```bash
docker-compose down -v
```

##  Penjelasan Komponen

### Backend (Express)
- **Port**: 5000
- **Endpoint**:
  - `GET /api/data` - Mengembalikan JSON dengan daftar items
  - `GET /health` - Health check endpoint

### Frontend (React)
- **Port**: 3000
- **Fitur**:
  - Menampilkan data dari backend
  - Tombol Refresh untuk memanggil ulang data
  - UI yang responsive dan menarik

### Dockerfile Backend
Menggunakan multi-stage build untuk mengecilkan ukuran image:
- Stage 1: Build dengan Node.js
- Stage 2: Runtime dengan Node.js Alpine (lebih kecil)

### Dockerfile Frontend
Menggunakan multi-stage build dengan Nginx:
- Stage 1: Build React app
- Stage 2: Serve dengan Nginx (lebih efisien)

### Docker Compose
- Mengelola kedua service (backend & frontend)
- Membuat network untuk komunikasi antar container
- Set health check untuk backend
- Automatic restart jika ada error

##  Command Penting

| Command | Fungsi |
|---------|--------|
| `docker-compose up` | Jalankan services |
| `docker-compose up --build` | Build & jalankan services |
| `docker-compose down` | Stop & remove containers |
| `docker-compose logs -f` | Lihat logs real-time |
| `docker-compose ps` | Lihat status containers |
| `docker-compose exec backend npm start` | Akses container backend |
| `docker-compose exec frontend npm start` | Akses container frontend |

##  Tips untuk Belajar CI/CD

1. **Modifikasi kode**: Edit `backend/server.js` atau `frontend/App.js` dan jalankan `docker-compose up --build` untuk rebuild
2. **Test API**: Gunakan tools seperti Postman atau curl untuk test API
3. **Monitor Performance**: Gunakan `docker stats` untuk melihat resource usage
4. **Explore Network**: Services berkomunikasi melalui service names (`backend:5000`)
