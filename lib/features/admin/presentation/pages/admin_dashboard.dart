import 'package:flutter/material.dart';
import 'package:eventkuy/data/local/database_helper.dart';
import 'package:eventkuy/features/auth/presentation/pages/registration_flow.dart';
import 'package:eventkuy/features/auth/views/login_screen.dart';

// ============================================================================
// SIMULASI LOGIN (Admin / EO / Peserta)
// ============================================================================
class LoginSimulationScreen extends StatefulWidget {
  const LoginSimulationScreen({super.key});

  @override
  State<LoginSimulationScreen> createState() => _LoginSimulationScreenState();
}

class _LoginSimulationScreenState extends State<LoginSimulationScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isLoading = false;

  void _login() async {
    if (_emailCtrl.text.isEmpty || _passwordCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email dan Password wajib diisi!'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    // Simulasi loading sejenak
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);

    String email = _emailCtrl.text.trim();
    String password = _passwordCtrl.text;

    // 1. Logika Hardcoded Admin
    if (email == 'admin@eventkuy.com' && password == 'password') {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
      );
      return;
    }

    // 2. Simulasi deteksi dari SQLite / sistem (Karena tabel user belum ada di SQLite, kita simulasikan)
    if (!mounted) return;
    if (email.toLowerCase().contains('eo')) {
      // Arahkan ke EO Dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const EODashboard()),
      );
    } else {
      // Arahkan ke Peserta Dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PesertaDashboard()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Login EventKuy'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.event_available, size: 80, color: Colors.indigo),
              const SizedBox(height: 24),
              const Text(
                'Selamat Datang',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.indigo),
              ),
              const SizedBox(height: 8),
              const Text(
                'Login Admin: admin@eventkuy.com / password\nLogin EO: gunakan email mengandung "eo"\nLogin Peserta: email lainnya',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _emailCtrl,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordCtrl,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Masuk', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }
}

// ============================================================================
// DASHBOARD ADMIN
// ============================================================================
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Tema warna Admin: Merah / BlueGrey
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel Kontrol Admin EventKuy 🛠️', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueGrey.shade900,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.redAccent,
          indicatorWeight: 4,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey.shade400,
          tabs: const [
            Tab(icon: Icon(Icons.verified_user), text: 'Persetujuan EO'),
            Tab(icon: Icon(Icons.list_alt), text: 'Semua Event'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          )
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _PendingApprovalsTab(),
          _AllEventsTab(),
        ],
      ),
    );
  }
}

// ============================================================================
// TAB 1: PERSETUJUAN EO (Pending Approvals)
// ============================================================================
class _PendingApprovalsTab extends StatefulWidget {
  const _PendingApprovalsTab();

  @override
  State<_PendingApprovalsTab> createState() => _PendingApprovalsTabState();
}

class _PendingApprovalsTabState extends State<_PendingApprovalsTab> {
  // Dummy data EO yang mendaftar
  final List<Map<String, dynamic>> _eoList = [
    {
      'id': '1',
      'name': 'EO Kreatif Jaya',
      'email': 'contact@kreatifjaya.com',
      'status': 'Menunggu Persetujuan'
    },
    {
      'id': '2',
      'name': 'Komunitas Musik Lokal',
      'email': 'admin@musiklokal.id',
      'status': 'Menunggu Persetujuan'
    },
  ];

  void _approveEO(int index) {
    setState(() {
      _eoList[index]['status'] = 'Disetujui';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_eoList[index]['name']} telah disetujui!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _rejectEO(int index) {
    setState(() {
      _eoList[index]['status'] = 'Ditolak';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_eoList[index]['name']} telah ditolak.'),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _eoList.length,
      itemBuilder: (context, index) {
        final eo = _eoList[index];
        final isPending = eo['status'] == 'Menunggu Persetujuan';
        final isApproved = eo['status'] == 'Disetujui';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        eo['name'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey.shade900,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isPending 
                            ? Colors.orange.shade100 
                            : (isApproved ? Colors.green.shade100 : Colors.red.shade100),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        eo['status'],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isPending 
                              ? Colors.orange.shade800 
                              : (isApproved ? Colors.green.shade800 : Colors.red.shade800),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(eo['email'], style: TextStyle(color: Colors.grey.shade600)),
                const SizedBox(height: 16),
                if (isPending)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.redAccent,
                            side: const BorderSide(color: Colors.redAccent),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () => _rejectEO(index),
                          child: const Text('Tolak'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () => _approveEO(index),
                          child: const Text('Setujui'),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ============================================================================
// TAB 2: SEMUA EVENT (Dari SQLite)
// ============================================================================
class _AllEventsTab extends StatefulWidget {
  const _AllEventsTab();

  @override
  State<_AllEventsTab> createState() => _AllEventsTabState();
}

class _AllEventsTabState extends State<_AllEventsTab> {
  List<Map<String, dynamic>> _events = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllEvents();
  }

  Future<void> _loadAllEvents() async {
    // Membaca seluruh data dari SQLite database
    try {
      final data = await DatabaseHelper().getAllEvents();
      if (!mounted) return;
      setState(() {
        _events = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _events = [];
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat event dari SQLite: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.redAccent));
    }

    if (_events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 60, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text('Belum ada event yang dipublikasikan.', style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAllEvents,
      color: Colors.redAccent,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _events.length,
        itemBuilder: (context, index) {
          final event = _events[index];
          final isFree = event['price'] == 0 || event['price'] == 0.0;
          
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                child: Icon(Icons.event_note, color: Colors.red.shade400),
              ),
              title: Text(event['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Kategori: ${event['category']} • ${event['isOnline'] == 1 ? 'Online' : 'Offline'}'),
                    Text('Tgl: ${event['date']}'),
                    Text(isFree ? 'Gratis' : 'Rp ${event['price']}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                  ],
                ),
              ),
              isThreeLine: true,
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () {
                  // Simulasi hapus (opsional)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Simulasi hapus oleh admin'), behavior: SnackBarBehavior.floating),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
