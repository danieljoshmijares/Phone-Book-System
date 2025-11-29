import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/contact.dart';
import 'services/firestore_service.dart';
import 'services/auth_service.dart';
import 'services/firebase_options.dart';
import 'pages/add_contact_page.dart';
import 'pages/edit_contact_page.dart';
import 'pages/view_contact_page.dart';
import 'pages/login_user_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My PhoneBook',
      theme: ThemeData(
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.selected)) {
              return const Color(0xFF1976D2); // Material Blue 700
            }
            return Colors.grey;
          }),
        ),
      ),
      home: const LoginUserPage(), //START APP WITH LOGIN PAGE
      routes: {
        '/home': (context) => const HomePage(),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

enum SortType { nameAsc, nameDesc, phoneAsc, phoneDesc }

class _HomePageState extends State<HomePage> {
  // ==================== VARIABLES ====================
  bool isSelectionMode = false;
  Set<int> selectedIndexes = {};

  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  // Contacts list (loaded from Firestore)
  List<Contact> contacts = [];

  // Services
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();

  // User name
  String userName = 'User';

  // Current sort type
  SortType currentSort = SortType.nameAsc;

  @override
  void initState() {
    super.initState();
    _loadContacts();
    _loadUserName();
    // Apply default sort after contacts load
    Future.delayed(Duration.zero, () {
      if (mounted) _sortByNameAsc();
    });
  }

  // Load user's full name
  Future<void> _loadUserName() async {
    final name = await _authService.getCurrentUserName();
    setState(() {
      userName = name;
    });
  }

  Widget _buildContactAvatar(Contact contact) {
    final hasImage = contact.imageUrl != null && contact.imageUrl!.isNotEmpty;

    if (hasImage) {
      return CircleAvatar(
        radius: 22,
        backgroundColor: Colors.grey.shade300,
        child: ClipOval(
          child: Image.network(
            contact.imageUrl!,
            width: 44,
            height: 44,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.person, size: 28, color: Colors.black54);
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Icon(Icons.person, size: 28, color: Colors.black54);
            },
          ),
        ),
      );
    }

    return CircleAvatar(
      radius: 22,
      backgroundColor: Colors.grey.shade300,
      child: const Icon(Icons.person, size: 28, color: Colors.black54),
    );
  }
  // ==================== SORTING METHODS ====================

  void _sortByNameAsc() {
    setState(() {
      currentSort = SortType.nameAsc;
      contacts.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
    });
  }

  void _sortByNameDesc() {
    setState(() {
      currentSort = SortType.nameDesc;
      contacts.sort(
        (a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()),
      );
    });
  }

  void _sortByPhoneAsc() {
    setState(() {
      currentSort = SortType.phoneAsc;
      contacts.sort((a, b) => a.number.compareTo(b.number));
    });
  }

  void _sortByPhoneDesc() {
    setState(() {
      currentSort = SortType.phoneDesc;
      contacts.sort((a, b) => b.number.compareTo(a.number));
    });
  }

  // Load contacts from Firestore on startup
  Future<void> _loadContacts() async {
    final loadedContacts = await _firestoreService.loadContacts();
    setState(() {
      contacts = loadedContacts;
    });
  }

  // Save contacts to Firestore
  Future<void> _saveContacts() async {
    await _firestoreService.saveContacts(contacts);
  }

  // ==================== NAVIGATION ====================
  Future<void> navigateToAddContact() async {
    final newContact = await Navigator.push<Contact>(
      context,
      MaterialPageRoute(builder: (context) => const AddContactPage()),
    );
    if (newContact != null) {
      // Add to Firestore and get the document ID
      await _firestoreService.addContact(newContact);
      setState(() => contacts.add(newContact));
    }
  }

  void navigateToViewContact(Contact contact) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewContactPage(
          contact: contact,
          onDelete: () async {
            // Delete from Firestore by ID
            if (contact.id != null) {
              await _firestoreService.deleteContact(contact.id!);
            }
            setState(() {
              contacts.remove(contact); // remove the contact from the list
            });
          },
        ),
      ),
    );
  }

  Future<void> navigateToEditContact(Contact contact) async {
    final updated = await Navigator.push<Contact>(
      context,
      MaterialPageRoute(
        builder: (context) => EditContactPage(contact: contact),
      ),
    );
    if (updated != null) {
      setState(() {
        contact.name = updated.name;
        contact.number = updated.number;
        contact.tel = updated.tel;
        contact.address = updated.address;
        contact.imageUrl = updated.imageUrl;
        contact.customFields = Map<String, String>.from(updated.customFields);
      });
      // Update in Firestore by ID
      await _firestoreService.updateContact(contact);
    }
  }

  // ==================== DELETE SELECTED ====================
  Future<void> deleteSelectedContacts() async {
    final count = selectedIndexes.length;

    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Contacts'),
        content: Text(
          'Are you sure you want to delete $count contact${count > 1 ? 's' : ''}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Proceed Anyway',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    // If confirmed, delete contacts
    if (confirm == true) {
      // Collect contacts to delete
      final contactsToDelete = selectedIndexes
          .map((index) => contacts[index])
          .toList();

      // Collect their IDs for Firestore deletion
      final idsToDelete = contactsToDelete
          .where((contact) => contact.id != null)
          .map((contact) => contact.id!)
          .toList();

      // Delete from Firestore
      if (idsToDelete.isNotEmpty) {
        await _firestoreService.deleteMultipleContacts(idsToDelete);
      }

      setState(() {
        // Remove from local list
        for (var contact in contactsToDelete) {
          contacts.remove(contact);
        }
        selectedIndexes.clear();
        isSelectionMode = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredContacts = contacts.where((contact) {
      final query = searchQuery.toLowerCase();
      return contact.name.toLowerCase().contains(query) ||
          contact.number.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            const Text(
              'My PhoneBook',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Text(
              'Welcome, $userName!',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text(
                'Logout',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                          await _authService.signOut();
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginUserPage(),
                            ),
                            (route) => false,
                          );
                        },
                        child: const Text(
                          'Logout',
                          style: TextStyle(color: Colors.redAccent),
                        ),
                      ),
                    ],
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF007BFF), Color(0xFF00B4D8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ==================== SEARCH BAR ====================
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.search, color: Colors.black54),
                              SizedBox(width: 8),
                              Text(
                                'Search Contacts',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: searchController,
                            onChanged: (value) =>
                                setState(() => searchQuery = value),
                            decoration: InputDecoration(
                              hintText: 'Enter name or number...',
                              border: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(12),
                                ),
                              ),
                              suffixIcon: searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        setState(() {
                                          searchController.clear();
                                          searchQuery = '';
                                        });
                                      },
                                    )
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ==================== BUTTONS ====================
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (isSelectionMode)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ElevatedButton.icon(
                              onPressed: () => setState(() {
                                selectedIndexes.clear();
                                isSelectionMode = false;
                              }),
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                              ),
                              label: const Text(
                                'Cancel',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 20,
                                  horizontal: 16,
                                ),
                              ),
                            ),
                          ),
                        if (isSelectionMode)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ElevatedButton.icon(
                              onPressed: deleteSelectedContacts,
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                              label: const Text(
                                'Delete',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 20,
                                  horizontal: 16,
                                ),
                              ),
                            ),
                          ),
                        if (!isSelectionMode)
                          ElevatedButton.icon(
                            onPressed: navigateToAddContact,
                            icon: const Icon(Icons.add, color: Colors.white),
                            label: const Text(
                              'Add Contact',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(
                                0xFF1976D2,
                              ), // Material Blue 700
                              padding: const EdgeInsets.symmetric(
                                vertical: 20,
                                horizontal: 16,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // My Contacts header with sort menu
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'My Contacts',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        // Sort menu button - always visible
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.sort, color: Colors.white, size: 28),
                          color: Colors.white,
                          onSelected: (value) {
                            if (value == 'name_asc') {
                              _sortByNameAsc();
                            } else if (value == 'name_desc') {
                              _sortByNameDesc();
                            } else if (value == 'phone_asc') {
                              _sortByPhoneAsc();
                            } else if (value == 'phone_desc') {
                              _sortByPhoneDesc();
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'name_asc',
                              child: Row(
                                children: [
                                  const Expanded(child: Text('Sort by Name (A–Z)')),
                                  if (currentSort == SortType.nameAsc)
                                    const Icon(Icons.check, color: Color(0xFF1976D2)),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'name_desc',
                              child: Row(
                                children: [
                                  const Expanded(child: Text('Sort by Name (Z–A)')),
                                  if (currentSort == SortType.nameDesc)
                                    const Icon(Icons.check, color: Color(0xFF1976D2)),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'phone_asc',
                              child: Row(
                                children: [
                                  const Expanded(child: Text('Sort by Phone (Ascending)')),
                                  if (currentSort == SortType.phoneAsc)
                                    const Icon(Icons.check, color: Color(0xFF1976D2)),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'phone_desc',
                              child: Row(
                                children: [
                                  const Expanded(child: Text('Sort by Phone (Descending)')),
                                  if (currentSort == SortType.phoneDesc)
                                    const Icon(Icons.check, color: Color(0xFF1976D2)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // ==================== SELECT ALL CHECKBOX ====================
                    if (isSelectionMode)
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 8),
                        child: Row(
                          children: [
                            Checkbox(
                              value: selectedIndexes.length == contacts.length && contacts.isNotEmpty,
                              onChanged: (value) {
                                setState(() {
                                  if (value == true) {
                                    // Select all contacts
                                    selectedIndexes = Set.from(
                                      List.generate(contacts.length, (index) => index),
                                    );
                                  } else {
                                    // Deselect all
                                    selectedIndexes.clear();
                                    isSelectionMode = false;
                                  }
                                });
                              },
                            ),
                            const Text(
                              'Select All',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // ==================== CONTACT LIST ====================
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredContacts.length,
                        itemBuilder: (context, index) {
                          final contact = filteredContacts[index];
                          final realIndex = contacts.indexOf(contact);
                          final isSelected = selectedIndexes.contains(
                            realIndex,
                          );
                          Color tileColor = isSelected
                              ? Colors.blue.shade100
                              : Colors.white;

                          return StatefulBuilder(
                            builder: (context, setTileState) {
                              bool isLongPressing = false;

                              return MouseRegion(
                                onEnter: (_) => setTileState(() {
                                  tileColor = isSelected
                                      ? Colors.blue.shade200
                                      : Colors.grey.shade200;
                                }),
                                onExit: (_) => setTileState(() {
                                  tileColor = isSelected
                                      ? Colors.blue.shade100
                                      : Colors.white;
                                }),
                                child: GestureDetector(
                                  onLongPressStart: (_) {
                                    setTileState(() {
                                      isLongPressing = true;
                                      tileColor = Colors.blue.shade300;
                                    });
                                  },
                                  onLongPressEnd: (_) {
                                    setTileState(() {
                                      isLongPressing = false;
                                    });
                                    setState(() {
                                      isSelectionMode = true;
                                      selectedIndexes.add(realIndex);
                                    });
                                  },
                                  child: AnimatedScale(
                                    scale: isLongPressing ? 0.95 : 1.0,
                                    duration: const Duration(milliseconds: 100),
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 4.0,
                                      ),
                                      decoration: BoxDecoration(
                                        color: tileColor,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isSelected
                                              ? Colors.blue
                                              : Colors.transparent,
                                        ),
                                      ),
                                      child: ListTile(
                                        leading: isSelectionMode
                                            ? Checkbox(
                                                value: isSelected,
                                                onChanged: (value) => setState(
                                                  () {
                                                    if (value == true) {
                                                      selectedIndexes.add(
                                                        realIndex,
                                                      );
                                                    } else {
                                                      selectedIndexes.remove(
                                                        realIndex,
                                                      );
                                                      if (selectedIndexes
                                                          .isEmpty) {
                                                        isSelectionMode = false;
                                                      }
                                                    }
                                                  },
                                                ),
                                              )
                                            : null,

                                        title: isSelectionMode
                                            ? Row(
                                                children: [
                                                  _buildContactAvatar(contact),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          contact.name,
                                                          style: const TextStyle(
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.w500,
                                                          ),
                                                        ),
                                                        const SizedBox(height: 4),
                                                        Text(
                                                          contact.number,
                                                          style: const TextStyle(
                                                            fontSize: 14,
                                                            color: Colors.black54,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : Row(
                                                children: [
                                                  _buildContactAvatar(contact),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          contact.name,
                                                          style: const TextStyle(
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.w500,
                                                          ),
                                                        ),
                                                        const SizedBox(height: 4),
                                                        Text(
                                                          contact.number,
                                                          style: const TextStyle(
                                                            fontSize: 14,
                                                            color: Colors.black54,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),

                                        trailing: !isSelectionMode
                                            ? IconButton(
                                                icon: const Icon(
                                                  Icons.edit_outlined,
                                                  color: Color(
                                                    0xFF1976D2,
                                                  ), // Material Blue 700
                                                ),
                                                onPressed: () =>
                                                    navigateToEditContact(
                                                      contact,
                                                    ),
                                              )
                                            : null,
                                        onTap: () {
                                          if (isSelectionMode) {
                                            setState(() {
                                              if (isSelected) {
                                                selectedIndexes.remove(
                                                  realIndex,
                                                );
                                                if (selectedIndexes.isEmpty) {
                                                  isSelectionMode = false;
                                                }
                                              } else {
                                                selectedIndexes.add(realIndex);
                                              }
                                            });
                                          } else {
                                            navigateToViewContact(contact);
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
