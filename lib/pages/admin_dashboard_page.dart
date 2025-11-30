import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';

class AdminDashboardPage extends StatefulWidget {
  final String adminRole; // 'admin' or 'superadmin'

  const AdminDashboardPage({super.key, required this.adminRole});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String adminName = 'Admin';
  int selectedTab = 0; // 0: Home, 1: Users, 2: Activity Logs, 3: Manage Admins (superadmin only)

  // Pagination
  int usersCurrentPage = 1;
  int logsCurrentPage = 1;
  int adminsCurrentPage = 1;
  final int itemsPerPage = 10;

  // Selection mode for Users tab
  bool usersSelectionMode = false;
  Set<int> selectedUserIndexes = {};

  // Selection mode for Manage Admins tab
  bool adminsSelectionMode = false;
  Set<int> selectedAdminIndexes = {};

  @override
  void initState() {
    super.initState();
    _loadAdminName();
  }

  Future<void> _loadAdminName() async {
    final name = await _authService.getCurrentUserName();
    setState(() {
      adminName = name;
    });
  }

  // Get current page title based on selectedTab
  String _getCurrentPageTitle() {
    switch (selectedTab) {
      case 0:
        return 'Home';
      case 1:
        return 'Users';
      case 2:
        return 'Activity Logs';
      case 3:
        return 'Manage Admins';
      default:
        return 'Admin Dashboard';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSuperAdmin = widget.adminRole == 'superadmin';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              _getCurrentPageTitle(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Text(
              'Welcome, $adminName!',
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
        iconTheme: const IconThemeData(color: Color(0xFF1976D2)),
      ),
      drawer: _buildDrawer(isSuperAdmin),
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
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: _buildTabContent(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Build Navigation Drawer
  Widget _buildDrawer(bool isSuperAdmin) {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF007BFF), Color(0xFF00B4D8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            // Drawer Header
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white,
                    child: Icon(
                      isSuperAdmin ? Icons.admin_panel_settings : Icons.manage_accounts,
                      size: 45,
                      color: const Color(0xFF1976D2),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    adminName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isSuperAdmin ? 'Super Admin' : 'Admin',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // Navigation Items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(
                    icon: Icons.home,
                    title: 'Home',
                    index: 0,
                  ),
                  _buildDrawerItem(
                    icon: Icons.people,
                    title: 'Users',
                    index: 1,
                  ),
                  _buildDrawerItem(
                    icon: Icons.history,
                    title: 'Activity Logs',
                    index: 2,
                  ),
                  if (isSuperAdmin)
                    _buildDrawerItem(
                      icon: Icons.admin_panel_settings,
                      title: 'Manage Admins',
                      index: 3,
                    ),
                ],
              ),
            ),

            // Logout at bottom
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
              ),
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.white),
                title: const Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () async {
                  await _authService.signOut();
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/',
                    (route) => false,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build individual drawer item
  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required int index,
  }) {
    final isSelected = selectedTab == index;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.white,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        onTap: () {
          setState(() => selectedTab = index);
          Navigator.pop(context); // Close drawer after selection
        },
      ),
    );
  }

  Widget _buildTabContent() {
    switch (selectedTab) {
      case 0:
        return _buildHomeTab();
      case 1:
        return _buildUsersTab();
      case 2:
        return _buildActivityLogsTab();
      case 3:
        return _buildManageAdminsTab();
      default:
        return const SizedBox();
    }
  }

  // HOME TAB (Analytics Dashboard)
  Widget _buildHomeTab() {
    final isSuperAdmin = widget.adminRole == 'superadmin';

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final allUsers = snapshot.data!.docs;

        // Filter regular users (role == 'user' or null for backward compatibility)
        final regularUsers = allUsers.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final role = data['role'];
          return role == null || role == 'user';
        }).toList();

        // Calculate user statistics
        final totalUsers = regularUsers.length;
        final activeUsers = regularUsers.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['disabled'] != true;
        }).length;
        final inactiveUsers = totalUsers - activeUsers;

        // Calculate admin statistics (for Super Admin only)
        int totalAdmins = 0;
        int activeAdmins = 0;
        int inactiveAdmins = 0;

        if (isSuperAdmin) {
          final admins = allUsers.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final role = data['role'];
            return role == 'admin' || role == 'superadmin';
          }).toList();

          totalAdmins = admins.length;
          activeAdmins = admins.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['disabled'] != true;
          }).length;
          inactiveAdmins = totalAdmins - activeAdmins;
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Dashboard Overview',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),

              // User Statistics Section
              _buildCompactStatSection(
                title: 'Users',
                icon: Icons.people,
                total: totalUsers,
                active: activeUsers,
                inactive: inactiveUsers,
              ),

              // Admin Statistics Section (Super Admin only)
              if (isSuperAdmin) ...[
                const SizedBox(height: 20),
                _buildCompactStatSection(
                  title: 'Admins',
                  icon: Icons.admin_panel_settings,
                  total: totalAdmins,
                  active: activeAdmins,
                  inactive: inactiveAdmins,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  // Helper method to build compact stat sections
  Widget _buildCompactStatSection({
    required String title,
    required IconData icon,
    required int total,
    required int active,
    required int inactive,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1976D2).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF1976D2).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              Icon(icon, color: const Color(0xFF1976D2), size: 28),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Total (main highlight)
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                'Total:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$total',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1976D2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Active and Inactive (compact row)
          Row(
            children: [
              // Active
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Active',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              '$active',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Inactive
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.cancel, color: Colors.orange, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Inactive',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              '$inactive',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // USERS TAB
  Widget _buildUsersTab() {
    return Column(
      children: [
        const Text(
          'User Management',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // Action buttons (when in selection mode)
        if (usersSelectionMode) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    selectedUserIndexes.clear();
                    usersSelectionMode = false;
                  });
                },
                icon: const Icon(Icons.close, color: Colors.white),
                label: const Text('Cancel', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: selectedUserIndexes.isEmpty ? null : () => _bulkToggleUserStatus(true),
                icon: const Icon(Icons.check_circle, color: Colors.white),
                label: const Text('Enable', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: selectedUserIndexes.isEmpty ? null : () => _bulkToggleUserStatus(false),
                icon: const Icon(Icons.cancel, color: Colors.white),
                label: const Text('Disable', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: selectedUserIndexes.isEmpty ? null : _bulkDeleteUsers,
                icon: const Icon(Icons.delete, color: Colors.white),
                label: const Text('Delete', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],

        // Selected count
        if (usersSelectionMode)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                '${selectedUserIndexes.length} selected',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ),

        // User list
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('users')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No users found'));
              }

              // Filter for users only (role == 'user' or no role field for old users)
              // Sort in-memory by createdAt (newest first)
              final allUsers = snapshot.data!.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final role = data['role'];
                return role == null || role == 'user'; // Include old users without role
              }).toList()
                ..sort((a, b) {
                  final aTime = (a.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
                  final bTime = (b.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
                  if (aTime == null || bTime == null) return 0;
                  return bTime.compareTo(aTime); // Descending order
                });

              // Pagination
              final totalPages = (allUsers.length / itemsPerPage).ceil();
              final startIndex = (usersCurrentPage - 1) * itemsPerPage;
              final endIndex = (startIndex + itemsPerPage).clamp(0, allUsers.length);
              final paginatedUsers = allUsers.sublist(
                startIndex.clamp(0, allUsers.length),
                endIndex,
              );

              return Column(
                children: [
                  // Select All checkbox (when in selection mode)
                  if (usersSelectionMode)
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 8),
                      child: Builder(
                        builder: (context) {
                          // Get indices of users on current page
                          final currentPageIndices = List.generate(
                            paginatedUsers.length,
                            (index) => allUsers.indexOf(paginatedUsers[index]),
                          ).toSet();

                          final allCurrentPageSelected = paginatedUsers.isNotEmpty &&
                              currentPageIndices.every((index) => selectedUserIndexes.contains(index));

                          return Row(
                            children: [
                              Checkbox(
                                value: allCurrentPageSelected,
                                onChanged: (value) {
                                  setState(() {
                                    if (value == true) {
                                      selectedUserIndexes.addAll(currentPageIndices);
                                    } else {
                                      selectedUserIndexes.removeAll(currentPageIndices);
                                      if (selectedUserIndexes.isEmpty) {
                                        usersSelectionMode = false;
                                      }
                                    }
                                  });
                                },
                              ),
                              const Text(
                                'Select All',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),

                  Expanded(
                    child: ListView.builder(
                      itemCount: paginatedUsers.length,
                      itemBuilder: (context, index) {
                        final user = paginatedUsers[index].data() as Map<String, dynamic>;
                        final userId = paginatedUsers[index].id;
                        final email = user['email'] ?? 'No email';
                        final fullName = user['fullName'] ?? 'No name';
                        final createdAt = user['createdAt'] as Timestamp?;
                        final disabled = user['disabled'] ?? false;

                        // Real index in allUsers list
                        final realIndex = allUsers.indexOf(paginatedUsers[index]);
                        final isSelected = selectedUserIndexes.contains(realIndex);

                        return StatefulBuilder(
                          builder: (context, setTileState) {
                            bool isLongPressing = false;
                            Color tileColor = isSelected ? Colors.blue.shade100 : Colors.white;

                            return MouseRegion(
                              onEnter: (_) => setTileState(() {
                                tileColor = isSelected ? Colors.blue.shade200 : Colors.grey.shade200;
                              }),
                              onExit: (_) => setTileState(() {
                                tileColor = isSelected ? Colors.blue.shade100 : Colors.white;
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
                                    usersSelectionMode = true;
                                    selectedUserIndexes.add(realIndex);
                                  });
                                },
                                child: AnimatedScale(
                                  scale: isLongPressing ? 0.95 : 1.0,
                                  duration: const Duration(milliseconds: 100),
                                  child: Card(
                                    margin: const EdgeInsets.symmetric(vertical: 4),
                                    color: tileColor,
                                    child: ListTile(
                                      leading: usersSelectionMode
                                          ? Checkbox(
                                              value: isSelected,
                                              onChanged: (value) {
                                                setState(() {
                                                  if (value == true) {
                                                    selectedUserIndexes.add(realIndex);
                                                  } else {
                                                    selectedUserIndexes.remove(realIndex);
                                                    if (selectedUserIndexes.isEmpty) {
                                                      usersSelectionMode = false;
                                                    }
                                                  }
                                                });
                                              },
                                            )
                                          : CircleAvatar(
                                              backgroundColor: disabled ? Colors.grey : const Color(0xFF1976D2),
                                              child: Text(
                                                fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U',
                                                style: const TextStyle(color: Colors.white),
                                              ),
                                            ),
                                      title: Text(
                                        fullName,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          decoration: disabled ? TextDecoration.lineThrough : null,
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(email),
                                          if (createdAt != null)
                                            Text(
                                              'Created: ${_formatTimestamp(createdAt)}',
                                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                                            ),
                                        ],
                                      ),
                                      trailing: usersSelectionMode
                                          ? null
                                          : Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                if (disabled)
                                                  const Chip(
                                                    label: Text('DISABLED', style: TextStyle(fontSize: 10)),
                                                    backgroundColor: Colors.red,
                                                    labelStyle: TextStyle(color: Colors.white),
                                                  )
                                                else
                                                  const Chip(
                                                    label: Text('ACTIVE', style: TextStyle(fontSize: 10)),
                                                    backgroundColor: Colors.green,
                                                    labelStyle: TextStyle(color: Colors.white),
                                                  ),
                                                const SizedBox(width: 8),
                                                ElevatedButton(
                                                  onPressed: () => _toggleUserStatus(userId, disabled, fullName),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: disabled ? Colors.green : Colors.orange,
                                                  ),
                                                  child: Text(
                                                    disabled ? 'Enable' : 'Disable',
                                                    style: const TextStyle(color: Colors.white),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                ElevatedButton(
                                                  onPressed: () => _deleteUser(userId, fullName),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.red,
                                                  ),
                                                  child: const Text(
                                                    'Delete',
                                                    style: TextStyle(color: Colors.white),
                                                  ),
                                                ),
                                              ],
                                            ),
                                      onTap: usersSelectionMode
                                          ? () {
                                              setState(() {
                                                if (isSelected) {
                                                  selectedUserIndexes.remove(realIndex);
                                                  if (selectedUserIndexes.isEmpty) {
                                                    usersSelectionMode = false;
                                                  }
                                                } else {
                                                  selectedUserIndexes.add(realIndex);
                                                }
                                              });
                                            }
                                          : null,
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

                  // Pagination controls
                  if (totalPages > 1)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // First page
                          IconButton(
                            onPressed: usersCurrentPage > 1
                                ? () => setState(() => usersCurrentPage = 1)
                                : null,
                            icon: const Icon(Icons.first_page),
                            color: Colors.black87,
                            disabledColor: Colors.grey,
                          ),
                          // Previous
                          IconButton(
                            onPressed: usersCurrentPage > 1
                                ? () => setState(() => usersCurrentPage--)
                                : null,
                            icon: const Icon(Icons.chevron_left),
                            color: Colors.black87,
                            disabledColor: Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          // Page numbers
                          ..._buildPageNumbers(usersCurrentPage, totalPages, (page) {
                            setState(() => usersCurrentPage = page);
                          }),
                          const SizedBox(width: 8),
                          // Next
                          IconButton(
                            onPressed: usersCurrentPage < totalPages
                                ? () => setState(() => usersCurrentPage++)
                                : null,
                            icon: const Icon(Icons.chevron_right),
                            color: Colors.black87,
                            disabledColor: Colors.grey,
                          ),
                          // Last page
                          IconButton(
                            onPressed: usersCurrentPage < totalPages
                                ? () => setState(() => usersCurrentPage = totalPages)
                                : null,
                            icon: const Icon(Icons.last_page),
                            color: Colors.black87,
                            disabledColor: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  // ACTIVITY LOGS TAB
  Widget _buildActivityLogsTab() {
    return Column(
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // Activity logs list
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('activityLogs')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No activity logs found'));
              }

              // Filter for user activities only (role == 'user' or no role for old logs)
              // Sort in-memory by timestamp (newest first)
              final allLogs = snapshot.data!.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final role = data['role'];
                return role == null || role == 'user'; // Include old logs without role
              }).toList()
                ..sort((a, b) {
                  final aTime = (a.data() as Map<String, dynamic>)['timestamp'] as Timestamp?;
                  final bTime = (b.data() as Map<String, dynamic>)['timestamp'] as Timestamp?;
                  if (aTime == null || bTime == null) return 0;
                  return bTime.compareTo(aTime); // Descending order
                });

              // Pagination
              final totalPages = (allLogs.length / itemsPerPage).ceil();
              final startIndex = (logsCurrentPage - 1) * itemsPerPage;
              final endIndex = (startIndex + itemsPerPage).clamp(0, allLogs.length);
              final paginatedLogs = allLogs.sublist(startIndex.clamp(0, allLogs.length), endIndex);

              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: paginatedLogs.length,
                      itemBuilder: (context, index) {
                        final log = paginatedLogs[index].data() as Map<String, dynamic>;
                        final timestamp = log['timestamp'] as Timestamp?;
                        final email = log['email'] ?? 'Unknown';
                        final fullName = log['fullName'] ?? 'Unknown';
                        final action = log['action'] ?? 'unknown';

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            leading: Icon(
                              action == 'register' ? Icons.person_add : Icons.login,
                              color: action == 'register' ? Colors.green : const Color(0xFF1976D2),
                            ),
                            title: Text(
                              timestamp != null ? _formatTimestamp(timestamp) : 'Unknown time',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('$email - $fullName'),
                                Text(
                                  action == 'register' ? 'Registered new account' : 'Logged in',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Pagination controls
                  if (totalPages > 1)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // First page button
                          IconButton(
                            onPressed: logsCurrentPage > 1
                                ? () => setState(() => logsCurrentPage = 1)
                                : null,
                            icon: const Icon(Icons.first_page),
                            color: const Color(0xFF1976D2),
                          ),

                          // Previous button
                          IconButton(
                            onPressed: logsCurrentPage > 1
                                ? () => setState(() => logsCurrentPage--)
                                : null,
                            icon: const Icon(Icons.chevron_left),
                            color: const Color(0xFF1976D2),
                          ),

                          const SizedBox(width: 8),

                          // Page numbers
                          ..._buildPageNumbers(logsCurrentPage, totalPages, (page) {
                            setState(() => logsCurrentPage = page);
                          }),

                          const SizedBox(width: 8),

                          // Next button
                          IconButton(
                            onPressed: logsCurrentPage < totalPages
                                ? () => setState(() => logsCurrentPage++)
                                : null,
                            icon: const Icon(Icons.chevron_right),
                            color: const Color(0xFF1976D2),
                          ),

                          // Last page button
                          IconButton(
                            onPressed: logsCurrentPage < totalPages
                                ? () => setState(() => logsCurrentPage = totalPages)
                                : null,
                            icon: const Icon(Icons.last_page),
                            color: const Color(0xFF1976D2),
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  // MANAGE ADMINS TAB (Super Admin only)
  Widget _buildManageAdminsTab() {
    return Column(
      children: [
        const Text(
          'Manage Administrators',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // Create Admin button
        ElevatedButton.icon(
          onPressed: _showCreateAdminDialog,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            'Create Admin',
            style: TextStyle(color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1976D2),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          ),
        ),

        const SizedBox(height: 16),

        // Admin list
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('users')
                .where('role', whereIn: ['admin', 'superadmin'])
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No admins found'));
              }

              // Sort in-memory by createdAt (newest first)
              final allAdmins = snapshot.data!.docs.toList()
                ..sort((a, b) {
                  final aTime = (a.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
                  final bTime = (b.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
                  if (aTime == null || bTime == null) return 0;
                  return bTime.compareTo(aTime); // Descending order
                });

              // Pagination
              final totalPages = (allAdmins.length / itemsPerPage).ceil();
              final startIndex = (adminsCurrentPage - 1) * itemsPerPage;
              final endIndex = (startIndex + itemsPerPage).clamp(0, allAdmins.length);
              final paginatedAdmins = allAdmins.sublist(startIndex.clamp(0, allAdmins.length), endIndex);

              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: paginatedAdmins.length,
                      itemBuilder: (context, index) {
                        final admin = paginatedAdmins[index].data() as Map<String, dynamic>;
                        final adminId = paginatedAdmins[index].id;
                        final email = admin['email'] ?? 'No email';
                        final fullName = admin['fullName'] ?? 'No name';
                        final role = admin['role'] ?? 'admin';
                        final createdAt = admin['createdAt'] as Timestamp?;
                        final disabled = admin['disabled'] ?? false;

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          color: role == 'superadmin' ? Colors.amber.shade50 : Colors.white,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: disabled
                                  ? Colors.grey
                                  : (role == 'superadmin' ? Colors.amber : const Color(0xFF1976D2)),
                              child: Icon(
                                role == 'superadmin' ? Icons.admin_panel_settings : Icons.manage_accounts,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                              fullName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                decoration: disabled ? TextDecoration.lineThrough : null,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(email),
                                Row(
                                  children: [
                                    Chip(
                                      label: Text(
                                        role == 'superadmin' ? 'SUPER ADMIN' : 'ADMIN',
                                        style: const TextStyle(fontSize: 10, color: Colors.white),
                                      ),
                                      backgroundColor: role == 'superadmin' ? Colors.amber : const Color(0xFF1976D2),
                                    ),
                                  ],
                                ),
                                if (createdAt != null)
                                  Text(
                                    'Created: ${_formatTimestamp(createdAt)}',
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                              ],
                            ),
                            trailing: role == 'superadmin'
                                ? null
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (disabled)
                                        const Chip(
                                          label: Text('DISABLED', style: TextStyle(fontSize: 10)),
                                          backgroundColor: Colors.red,
                                          labelStyle: TextStyle(color: Colors.white),
                                        )
                                      else
                                        const Chip(
                                          label: Text('ACTIVE', style: TextStyle(fontSize: 10)),
                                          backgroundColor: Colors.green,
                                          labelStyle: TextStyle(color: Colors.white),
                                        ),
                                      const SizedBox(width: 8),
                                      ElevatedButton(
                                        onPressed: () => _toggleAdminStatus(adminId, disabled, fullName),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: disabled ? Colors.green : Colors.orange,
                                        ),
                                        child: Text(
                                          disabled ? 'Enable' : 'Disable',
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      ElevatedButton(
                                        onPressed: () => _deleteAdmin(adminId, fullName),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                        ),
                                        child: const Text(
                                          'Delete',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Pagination controls
                  if (totalPages > 1)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // First page button
                          IconButton(
                            onPressed: adminsCurrentPage > 1
                                ? () => setState(() => adminsCurrentPage = 1)
                                : null,
                            icon: const Icon(Icons.first_page),
                            color: const Color(0xFF1976D2),
                          ),

                          // Previous button
                          IconButton(
                            onPressed: adminsCurrentPage > 1
                                ? () => setState(() => adminsCurrentPage--)
                                : null,
                            icon: const Icon(Icons.chevron_left),
                            color: const Color(0xFF1976D2),
                          ),

                          const SizedBox(width: 8),

                          // Page numbers
                          ..._buildPageNumbers(adminsCurrentPage, totalPages, (page) {
                            setState(() => adminsCurrentPage = page);
                          }),

                          const SizedBox(width: 8),

                          // Next button
                          IconButton(
                            onPressed: adminsCurrentPage < totalPages
                                ? () => setState(() => adminsCurrentPage++)
                                : null,
                            icon: const Icon(Icons.chevron_right),
                            color: const Color(0xFF1976D2),
                          ),

                          // Last page button
                          IconButton(
                            onPressed: adminsCurrentPage < totalPages
                                ? () => setState(() => adminsCurrentPage = totalPages)
                                : null,
                            icon: const Icon(Icons.last_page),
                            color: const Color(0xFF1976D2),
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  // Helper methods
  String _formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _toggleUserStatus(String userId, bool currentlyDisabled, String userName) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'disabled': !currentlyDisabled,
      });

      // Show success dialog (like login success)
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.green.shade50,
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green.shade700, size: 28),
              const SizedBox(width: 8),
              const Text(
                'Success!',
                style: TextStyle(color: Colors.green),
              ),
            ],
          ),
          content: Text(
            currentlyDisabled
                ? 'User "$userName" has been enabled successfully.'
                : 'User "$userName" has been disabled successfully.',
            style: const TextStyle(fontSize: 16),
          ),
        ),
      );

      // Auto-dismiss after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pop(context);
      });
    } catch (e) {
      // Show error dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('Failed to update user status: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _deleteUser(String userId, String userName) async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete user "$userName"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _firestore.collection('users').doc(userId).delete();

        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.green.shade50,
            title: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green.shade700, size: 28),
                const SizedBox(width: 8),
                const Text(
                  'Deleted!',
                  style: TextStyle(color: Colors.green),
                ),
              ],
            ),
            content: Text(
              'User "$userName" has been deleted successfully.',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        );

        // Auto-dismiss after 2 seconds
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pop(context);
        });
      } catch (e) {
        // Show error dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to delete user: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  // Bulk toggle user status (enable/disable)
  Future<void> _bulkToggleUserStatus(bool enable) async {
    if (selectedUserIndexes.isEmpty) return;

    final count = selectedUserIndexes.length;
    final action = enable ? 'enable' : 'disable';

    // Show confirmation
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${enable ? 'Enable' : 'Disable'} Users'),
        content: Text('Are you sure you want to $action $count user${count > 1 ? 's' : ''}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Proceed'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        // Fetch current users to get IDs
        final snapshot = await _firestore.collection('users').get();
        final allUsers = snapshot.docs.where((doc) {
          final data = doc.data();
          final role = data['role'];
          return role == null || role == 'user';
        }).toList()
          ..sort((a, b) {
            final aTime = (a.data())['createdAt'] as Timestamp?;
            final bTime = (b.data())['createdAt'] as Timestamp?;
            if (aTime == null || bTime == null) return 0;
            return bTime.compareTo(aTime);
          });

        // Update selected users
        for (final index in selectedUserIndexes) {
          if (index < allUsers.length) {
            await _firestore.collection('users').doc(allUsers[index].id).update({
              'disabled': !enable,
            });
          }
        }

        setState(() {
          selectedUserIndexes.clear();
          usersSelectionMode = false;
        });

        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.green.shade50,
            title: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green.shade700, size: 28),
                const SizedBox(width: 8),
                const Text('Success!', style: TextStyle(color: Colors.green)),
              ],
            ),
            content: Text('$count user${count > 1 ? 's' : ''} ${enable ? 'enabled' : 'disabled'} successfully.'),
          ),
        );

        // Auto-dismiss after 2 seconds
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pop(context);
        });
      } catch (e) {
        print('Error bulk toggling users: $e');
      }
    }
  }

  // Bulk delete users
  Future<void> _bulkDeleteUsers() async {
    if (selectedUserIndexes.isEmpty) return;

    final count = selectedUserIndexes.length;

    // Show confirmation
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Users'),
        content: Text('Are you sure you want to delete $count user${count > 1 ? 's' : ''}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        // Fetch current users to get IDs
        final snapshot = await _firestore.collection('users').get();
        final allUsers = snapshot.docs.where((doc) {
          final data = doc.data();
          final role = data['role'];
          return role == null || role == 'user';
        }).toList()
          ..sort((a, b) {
            final aTime = (a.data())['createdAt'] as Timestamp?;
            final bTime = (b.data())['createdAt'] as Timestamp?;
            if (aTime == null || bTime == null) return 0;
            return bTime.compareTo(aTime);
          });

        // Delete selected users
        for (final index in selectedUserIndexes) {
          if (index < allUsers.length) {
            await _firestore.collection('users').doc(allUsers[index].id).delete();
          }
        }

        setState(() {
          selectedUserIndexes.clear();
          usersSelectionMode = false;
        });

        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.green.shade50,
            title: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green.shade700, size: 28),
                const SizedBox(width: 8),
                const Text('Deleted!', style: TextStyle(color: Colors.green)),
              ],
            ),
            content: Text('$count user${count > 1 ? 's' : ''} deleted successfully.'),
          ),
        );

        // Auto-dismiss after 2 seconds
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pop(context);
        });
      } catch (e) {
        print('Error bulk deleting users: $e');
      }
    }
  }

  void _showCreateAdminDialog() {
    final emailCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    bool obscurePassword = true;
    final Set<String> touchedFields = {};

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Create Admin Account'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Full Name field
              Focus(
                onFocusChange: (hasFocus) {
                  if (!hasFocus) {
                    setDialogState(() {
                      touchedFields.add('fullName');
                    });
                  }
                },
                child: TextField(
                  controller: nameCtrl,
                  onChanged: (_) {
                    if (touchedFields.contains('fullName')) {
                      setDialogState(() {});
                    }
                  },
                  decoration: InputDecoration(
                    label: RichText(
                      text: const TextSpan(
                        text: 'Full Name',
                        style: TextStyle(color: Colors.black87, fontSize: 16),
                        children: [
                          TextSpan(
                            text: ' *',
                            style: TextStyle(color: Colors.red, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    errorText: touchedFields.contains('fullName') && nameCtrl.text.trim().isEmpty
                        ? 'This is a required field'
                        : null,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Email field
              Focus(
                onFocusChange: (hasFocus) {
                  if (!hasFocus) {
                    setDialogState(() {
                      touchedFields.add('email');
                    });
                  }
                },
                child: TextField(
                  controller: emailCtrl,
                  onChanged: (_) {
                    if (touchedFields.contains('email')) {
                      setDialogState(() {});
                    }
                  },
                  decoration: InputDecoration(
                    label: RichText(
                      text: const TextSpan(
                        text: 'Email',
                        style: TextStyle(color: Colors.black87, fontSize: 16),
                        children: [
                          TextSpan(
                            text: ' *',
                            style: TextStyle(color: Colors.red, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    errorText: touchedFields.contains('email') && emailCtrl.text.trim().isEmpty
                        ? 'This is a required field'
                        : null,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Password field
              Focus(
                onFocusChange: (hasFocus) {
                  if (!hasFocus) {
                    setDialogState(() {
                      touchedFields.add('password');
                    });
                  }
                },
                child: TextField(
                  controller: passwordCtrl,
                  obscureText: obscurePassword,
                  onChanged: (_) {
                    if (touchedFields.contains('password')) {
                      setDialogState(() {});
                    }
                  },
                  decoration: InputDecoration(
                    label: RichText(
                      text: const TextSpan(
                        text: 'Password',
                        style: TextStyle(color: Colors.black87, fontSize: 16),
                        children: [
                          TextSpan(
                            text: ' *',
                            style: TextStyle(color: Colors.red, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    errorText: touchedFields.contains('password') && passwordCtrl.text.trim().isEmpty
                        ? 'This is a required field'
                        : null,
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setDialogState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty ||
                    emailCtrl.text.trim().isEmpty ||
                    passwordCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('All fields are required'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final result = await _authService.register(
                  email: emailCtrl.text.trim(),
                  password: passwordCtrl.text.trim(),
                  fullName: nameCtrl.text.trim(),
                  role: 'admin',
                );

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result['message']),
                    backgroundColor: result['success'] ? Colors.green : Colors.red,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1976D2),
              ),
              child: const Text('Create', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteAdmin(String adminId, String adminName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Admin'),
        content: Text('Are you sure you want to delete admin "$adminName"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _firestore.collection('users').doc(adminId).delete();

        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.green.shade50,
            title: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green.shade700, size: 28),
                const SizedBox(width: 8),
                const Text(
                  'Deleted!',
                  style: TextStyle(color: Colors.green),
                ),
              ],
            ),
            content: Text(
              'Admin "$adminName" has been deleted successfully.',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        );

        // Auto-dismiss after 2 seconds
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pop(context);
        });
      } catch (e) {
        // Show error dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to delete admin: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _toggleAdminStatus(String adminId, bool currentlyDisabled, String adminName) async {
    try {
      await _firestore.collection('users').doc(adminId).update({
        'disabled': !currentlyDisabled,
      });

      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.green.shade50,
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green.shade700, size: 28),
              const SizedBox(width: 8),
              const Text(
                'Success!',
                style: TextStyle(color: Colors.green),
              ),
            ],
          ),
          content: Text(
            currentlyDisabled
                ? 'Admin "$adminName" has been enabled successfully.'
                : 'Admin "$adminName" has been disabled successfully.',
            style: const TextStyle(fontSize: 16),
          ),
        ),
      );

      // Auto-dismiss after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pop(context);
      });
    } catch (e) {
      // Show error dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('Failed to update admin status: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  // Build page number buttons (max 5 visible)
  List<Widget> _buildPageNumbers(int currentPage, int totalPages, Function(int) onPageSelected) {
    List<Widget> pageButtons = [];

    // Calculate range of pages to show (max 5)
    int startPage = currentPage - 2;
    int endPage = currentPage + 2;

    if (startPage < 1) {
      startPage = 1;
      endPage = (totalPages < 5) ? totalPages : 5;
    }

    if (endPage > totalPages) {
      endPage = totalPages;
      startPage = (totalPages < 5) ? 1 : totalPages - 4;
    }

    for (int i = startPage; i <= endPage; i++) {
      final isCurrentPage = i == currentPage;
      pageButtons.add(
        GestureDetector(
          onTap: () => onPageSelected(i),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isCurrentPage ? const Color(0xFF1976D2) : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isCurrentPage ? const Color(0xFF1976D2) : Colors.grey.shade400,
                width: 1,
              ),
            ),
            child: Text(
              '$i',
              style: TextStyle(
                color: isCurrentPage ? Colors.white : Colors.black87,
                fontWeight: isCurrentPage ? FontWeight.bold : FontWeight.normal,
                fontSize: 16,
              ),
            ),
          ),
        ),
      );
    }

    return pageButtons;
  }
}
