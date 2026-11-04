import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:faker/faker.dart' hide Color; // ← FIX 1: hide Color dari faker
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:avatar_glow/avatar_glow.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  Intl.defaultLocale = 'id_ID';
  runApp(const ContactApp());
}

class Contact {
  final String name;
  final String phone;
  final String email;
  final DateTime addedAt;
  final String category;

  const Contact({
    required this.name,
    required this.phone,
    required this.email,
    required this.addedAt,
    required this.category,
  });
}

class ContactApp extends StatelessWidget {
  const ContactApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Daftar Kontak',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6750A4)),
        scaffoldBackgroundColor: const Color(0xFFF7F5FC),
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int selectedIndex = 0;
  String selectedCategory = 'Semua';

  final List<String> categories = const ['Semua', 'Keluarga', 'Teman', 'Kerja'];
  late final List<Contact> contacts;

  @override
  void initState() {
    super.initState();
    contacts = _generateContacts();
  }

  List<Contact> _generateContacts() {
    final faker = Faker();
    const categoryList = ['Keluarga', 'Teman', 'Kerja'];

    return List.generate(20, (index) {
      return Contact(
        name: faker.person.name(),
        phone: '+62 8${(100000000 + index * 7919).toString().padLeft(9, '0')}',
        email: faker.internet.email(),
        addedAt: DateTime.now().subtract(Duration(days: index * 3 + 1)),
        category: categoryList[index % categoryList.length],
      );
    });
  }

  List<Contact> get _filteredContacts {
    if (selectedCategory == 'Semua') return contacts;
    return contacts.where((c) => c.category == selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _contactsPage(),
      _searchPage(),
      _profilePage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              const [
                'Daftar Kontak',
                'Cari Kontak',
                'Profil Saya'
              ][selectedIndex],
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Kelola koneksi Anda dengan mudah',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
      body: IndexedStack(index: selectedIndex, children: pages),
      bottomNavigationBar: ConvexAppBar(
        style: TabStyle.react,
        backgroundColor: const Color(0xFF6750A4),
        activeColor: Colors.white,
        color: Colors.white70,
        initialActiveIndex: 0,
        items: const [
          TabItem(icon: Icons.contacts_rounded, title: 'Kontak'),
          TabItem(icon: Icons.search_rounded, title: 'Cari'),
          TabItem(icon: Icons.person_rounded, title: 'Profil'),
        ],
        onTap: (index) => setState(() => selectedIndex = index),
      ),
    );
  }

  Widget _contactsPage() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6750A4), Color(0xFF9985D5)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.people_alt_rounded,
                    color: Colors.white, size: 42),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total Kontak',
                          style: TextStyle(color: Colors.white70)),
                      Text(
                        '${contacts.length} kontak tersimpan',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              final contact = contacts[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                color: Colors.white,
                elevation: 1,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: const Color(0xFFEAE3FA),
                        child: Text(
                          contact.name.isNotEmpty
                              ? contact.name[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: Color(0xFF6750A4),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              contact.name,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 7),
                            _contactDetail(Icons.phone_outlined, contact.phone),
                            const SizedBox(height: 4),
                            _contactDetail(Icons.email_outlined, contact.email),
                            const SizedBox(height: 9),
                            Text(
                              'Ditambahkan pada ${DateFormat('dd MMMM yyyy', 'id_ID').format(contact.addedAt)}',
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.grey),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 9, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEAE3FA),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                contact.category,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF6750A4),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _contactDetail(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 15, color: const Color(0xFF6750A4)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(value,
              style: const TextStyle(fontSize: 12, color: Colors.black54)),
        ),
      ],
    );
  }

  Widget _searchPage() {
    final results = _filteredContacts;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.manage_search_rounded,
                  size: 45, color: Color(0xFF6750A4)),
              const SizedBox(height: 12),
              const Text(
                'Cari berdasarkan kategori',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Pilih kategori kontak dari daftar offline.',
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 20),
              DropdownSearch<String>(
                items: (filter, loadProps) => categories,
                selectedItem: selectedCategory,
                popupProps: const PopupProps.menu(showSearchBox: true),
                decoratorProps: const DropDownDecoratorProps(
                  decoration: InputDecoration(
                    labelText: 'Kategori kontak',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                ),
                onChanged: (value) {
                  if (value != null) setState(() => selectedCategory = value);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Hasil pencarian (${results.length})',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        if (results.isEmpty)
          const Center(child: Text('Tidak ada kontak dalam kategori ini.'))
        else
          ...results.map(
            (contact) => Card(
              color: Colors.white,
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFEAE3FA),
                  child: Icon(Icons.person, color: Color(0xFF6750A4)),
                ),
                title: Text(contact.name),
                subtitle: Text(contact.phone),
                trailing:
                    const Icon(Icons.chevron_right, color: Color(0xFF6750A4)),
              ),
            ),
          ),
      ],
    );
  }

  Widget _profilePage() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            AvatarGlow(
              glowColor: const Color(0xFF9985D5),
              // ← FIX 2: endRadius dihapus, tidak ada di avatar_glow versi baru
              child: const Material(
                elevation: 8,
                shape: CircleBorder(),
                color: Colors.transparent,
                child: CircleAvatar(
                  radius: 65,
                  backgroundColor: Color(0xFFEAE3FA),
                  backgroundImage:
                      NetworkImage('https://i.pravatar.cc/300?img=12'),
                ),
              ),
            ),
            const SizedBox(height: 25),
            const Text(
              'Pengguna Kontak',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('pengguna@email.com',
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 25),
            Card(
              color: Colors.white,
              child: Column(
                children: [
                  _profileInfo(Icons.contacts_outlined, 'Total kontak',
                      '${contacts.length} kontak'),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _profileInfo(
                      Icons.category_outlined, 'Kategori', '3 kategori'),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _profileInfo(
                      Icons.calendar_month_outlined, 'Status akun', 'Aktif'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Aplikasi Daftar Kontak • Pertemuan 6',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileInfo(IconData icon, String title, String value) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF6750A4)),
      title: Text(title),
      trailing:
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}
