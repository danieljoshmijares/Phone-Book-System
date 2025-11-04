import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Phonebook',
        home: const HomePage(),
      );
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

  // SAMPLE DATA
  final List<Map<String, String>> contacts = [
    {'name': 'A1', 'number': '1000', 'tel': '1zz', 'address': '2b a'}, //
    {'name': 'A2', 'number': '2000', 'tel': '2zz', 'address': '4b a'}, //
    {'name': 'A3', 'number': '3000', 'tel': '3zz', 'address': '6b a'}, //
    {'name': 'A4', 'number': '4000', 'tel': '4zz', 'address': '8b a'}, // 
    {'name': 'A5', 'number': '5000', 'tel': '5zz', 'address': '10b a'}, //
    {'name': 'A6', 'number': '6000', 'tel': '6zz', 'address': '12b a'}, //
  ]; //

  // ==================== ADD CONTACT ====================
  void addContact() => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Add Contact'),
          content: const SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(decoration: InputDecoration(labelText: 'Full Name')),
              TextField(decoration: InputDecoration(labelText: 'Phone Number')),
              TextField(decoration: InputDecoration(labelText: 'Tel. Number')),
              TextField(decoration: InputDecoration(labelText: 'Home Address')),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(onPressed: () {}, child: const Text('Clear')),
            ElevatedButton(onPressed: () {}, child: const Text('Save')),
          ],
        ),
      );

  // ==================== VIEW CONTACT ====================
  void viewContact(Map<String, String> contact) => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Center(
            child: Text('View Contact',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue)),
          ),
          content: SingleChildScrollView(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 8),
              const Text('Name:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              Text(contact['name']!, style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 12),
              const Text('Mobile Number:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              Text(contact['number']!, style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 12),
              const Text('Tel Number:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              Text(contact['tel']!, style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 12),
              const Text('Home Address:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              Text(contact['address']!, style: const TextStyle(fontSize: 18)),
            ]),
          ),
          actions: [
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(foregroundColor: Colors.blue, textStyle: const TextStyle(fontSize: 18)),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      );

  // ==================== EDIT CONTACT ====================
  void editContact(Map<String, String> contact) {
    final name = TextEditingController(text: contact['name']);
    final num = TextEditingController(text: contact['number']);
    final tel = TextEditingController(text: contact['tel']);
    final address = TextEditingController(text: contact['address']);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Center(
          child: Text('Edit Contact',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue)),
        ),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: 'Full Name')),
            TextField(controller: num, decoration: const InputDecoration(labelText: 'Phone Number')),
            TextField(controller: tel, decoration: const InputDecoration(labelText: 'Tel. Number')),
            TextField(controller: address, decoration: const InputDecoration(labelText: 'Home Address')),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(onPressed: (

          ) {}, child: const Text('Clear')),
          ElevatedButton(onPressed: 
          () {}, child: const Text('Update')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar( //header ================= 1
          title: const Text('My Phonebook',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF007BFF), Color(0xFF00B4D8)],
                begin: Alignment.topLeft, end: Alignment.bottomRight),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
               
                const SizedBox(height: 16),

                // ==================== SEARCH BAR ==================== WALA pa onchange
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(12)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Row(children: [
                      Icon(Icons.search, color: Colors.black54),
                      SizedBox(width: 8),
                      Text('Search Contacts', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ]),
                    const SizedBox(height: 8),
                    const TextField(
                      decoration: InputDecoration(
                        hintText: 'Enter name or number...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            borderSide: BorderSide(color: Colors.grey, width: 1)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            borderSide: BorderSide(color: Colors.blue, width: 1.5)),
                        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 16),

                // ==================== BUTTONS ==================== add delete cancel
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  if (isSelectionMode)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ElevatedButton.icon(
                        onPressed: (
                          
                        ) {}, // DELETE BUTTON
                        icon: const Icon(Icons.delete, color: Colors.white),
                        label: const Text('Delete', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16)),
                      ),
                    ),
                  if (isSelectionMode)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ElevatedButton.icon(
                        onPressed: () => setState(() {
                          selectedIndexes.clear();
                          isSelectionMode = false;
                        }),
                        icon: const Icon(Icons.close, color: Colors.white),
                        label: const Text('Cancel', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16)),
                      ),
                    ),
                  ElevatedButton.icon(
                    onPressed: addContact, // edit in add contact
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text('Add Contact', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16)),
                  ),
                ]),
                const SizedBox(height: 16),

                const Text('My Contacts',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 8),

                // ==================== CONTACT LIST ====================
                Expanded(
                  child: ListView.builder(
                    itemCount: contacts.length,
                    itemBuilder: (context, index) {
                      final contact = contacts[index]; // Get current contact data
                      bool isSelected = selectedIndexes.contains(index); // Check if contact is selected
                      Color tileColor = isSelected ? Colors.blue.shade100 : Colors.white;
                      return StatefulBuilder(builder: (context, setTileState) {
                        return MouseRegion( // Hover mouse effect
                          onEnter: (_) => setTileState(() {
                            tileColor = isSelected ? Colors.blue.shade200 : Colors.grey.shade200;
                          }),
                          onExit: (_) => setTileState(() {
                            tileColor = isSelected ? Colors.blue.shade100 : Colors.white;
                          }),
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                              color: tileColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: isSelected ? Colors.blue : Colors.transparent),
                            ),
                            child: ListTile(
                              // Checkbox logic (for multiple selection)
                              leading: isSelectionMode
                                  ? Checkbox(
                                      value: isSelected,
                                      onChanged: (value) => setState(() {
                                        if (value == true) {selectedIndexes.add(index);} // add to checkbox
                                        else {
                                          selectedIndexes.remove(index); // remove from checkbox
                                          if (selectedIndexes.isEmpty) isSelectionMode = false; // exit mode if none
                                        }
                                      }),
                                    )
                                  : null,
                              // Contact name and number display
                              title: Text(contact['name']!),
                              subtitle: Text(contact['number']!),
                              // Edit button
                              trailing: !isSelectionMode
                                  ? IconButton(
                                      icon: const Icon(Icons.edit_outlined, color: Colors.indigo),
                                      onPressed: () => editContact(contact), // EDIT CONTACT FUNCTION
                                    )
                                  : null,
                              // for view contact
                              onTap: () {
                                if (isSelectionMode) {
                                  setState(() {
                                    if (isSelected) {
                                      selectedIndexes.remove(index);
                                      if (selectedIndexes.isEmpty) isSelectionMode = false;
                                    } else {selectedIndexes.add(index);}
                                  });
                                } else {viewContact(contact);}
                              },
                              // Long press logic for checkbox
                              onLongPress: () => setState(() {
                                isSelectionMode = true;
                                selectedIndexes.add(index); //add to index selec
                              }),
                            ),
                          ),
                        );
                      });
                    },
                  ),
                ),
              ]),
            ),
          ),
        ),
      );
}
