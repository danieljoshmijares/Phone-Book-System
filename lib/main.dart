import 'package:flutter/material.dart';
import '../models/contact.dart';
import 'services/contact_storage.dart';
import 'pages/add_contact_page.dart';
import 'pages/edit_contact_page.dart';
import 'pages/view_contact_page.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Phonebook',
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // ==================== VARIABLES ====================
  bool isSelectionMode = false;
  Set<int> selectedIndexes = {};

  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  // Contacts list (loaded from storage)
  List<Contact> contacts = [];

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  // Load contacts from storage on startup
  Future<void> _loadContacts() async {
    final loadedContacts = await ContactStorage.loadContacts();
    setState(() {
      contacts = loadedContacts;
    });
  }

  // Save contacts to storage
  Future<void> _saveContacts() async {
    await ContactStorage.saveContacts(contacts);
  }

  // ==================== NAVIGATION ====================
  Future<void> navigateToAddContact() async {
    final newContact = await Navigator.push<Contact>(
      context,
      MaterialPageRoute(builder: (context) => const AddContactPage()),
    );
    if (newContact != null) {
      setState(() => contacts.add(newContact));
      await _saveContacts(); // Save after adding
    }
  }

void navigateToViewContact(Contact contact) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ViewContactPage(
        contact: contact,
        onDelete: () {
          setState(() {
            contacts.remove(contact); // remove the contact from the list
          });
          _saveContacts(); // Save after deleting
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
      });
      await _saveContacts(); // Save after editing
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
        content: Text('Are you sure you want to delete $count contact${count > 1 ? 's' : ''}?'),
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
      setState(() {
        contacts.removeWhere(
          (contact) => selectedIndexes.contains(contacts.indexOf(contact)),
        );
        selectedIndexes.clear();
        isSelectionMode = false;
      });
      _saveContacts(); // Save after bulk delete
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
        title: const Text(
          'My Phonebook',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
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
                            borderRadius: BorderRadius.all(Radius.circular(12)),
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
                          icon: const Icon(Icons.close, color: Colors.white),
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
                          icon: const Icon(Icons.delete, color: Colors.white),
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
                          backgroundColor: Colors.indigo,
                          padding: const EdgeInsets.symmetric(
                            vertical: 20,
                            horizontal: 16,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 16),

                const Text(
                  'My Contacts',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),

                // ==================== CONTACT LIST ====================
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredContacts.length,
                    itemBuilder: (context, index) {
                      final contact = filteredContacts[index];
                      final realIndex = contacts.indexOf(contact);
                      final isSelected = selectedIndexes.contains(realIndex);
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
                                  margin: const EdgeInsets.symmetric(vertical: 4.0),
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
                                            onChanged: (value) => setState(() {
                                              if (value == true) {
                                                selectedIndexes.add(realIndex);
                                              } else {
                                                selectedIndexes.remove(realIndex);
                                                if (selectedIndexes.isEmpty) {
                                                  isSelectionMode = false;
                                                }
                                              }
                                            }),
                                          )
                                        : null,
                                    title: Text(contact.name),
                                    subtitle: Text(contact.number),
                                    trailing: !isSelectionMode
                                        ? IconButton(
                                            icon: const Icon(
                                              Icons.edit_outlined,
                                              color: Colors.indigo,
                                            ),
                                            onPressed: () =>
                                                navigateToEditContact(contact),
                                          )
                                        : null,
                                    onTap: () {
                                      if (isSelectionMode) {
                                        setState(() {
                                          if (isSelected) {
                                            selectedIndexes.remove(realIndex);
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
