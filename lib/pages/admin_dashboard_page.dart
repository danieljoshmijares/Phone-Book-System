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

  @override
  Widget build(BuildContext context) {
    final isSuperAdmin = widget.adminRole == 'superadmin';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            const Text(
              'Admin Dashboard',
              style: TextStyle(
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
              onPressed: () async {
                await _authService.signOut();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (route) => false,
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
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Tab buttons
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildTabButton('Home', 0),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildTabButton('Users', 1),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildTabButton('Activity Logs', 2),
                          ),
                          if (isSuperAdmin) ...[
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildTabButton('Manage Admins', 3),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Tab content
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: _buildTabContent(),
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

  Widget _buildTabButton(String title, int index) {
    final isSelected = selectedTab == index;
    return ElevatedButton(
      onPressed: () => setState(() => selectedTab = index),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? const Color(0xFF1976D2) : Colors.grey.shade300,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: FontWeight.bold,
        ),
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
              const Text(
                'User Statistics',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: 'Total Users',
                      value: '$totalUsers',
                      icon: Icons.people,
                      color: const Color(0xFF1976D2), // Blue
                      isPrimary: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      title: 'Active Users',
                      value: '$activeUsers',
                      icon: Icons.check_circle,
                      color: Colors.green,
                      isPrimary: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      title: 'Inactive Users',
                      value: '$inactiveUsers',
                      icon: Icons.cancel,
                      color: Colors.orange,
                      isPrimary: false,
                    ),
                  ),
                ],
              ),

              // Admin Statistics Section (Super Admin only)
              if (isSuperAdmin) ...[
                const SizedBox(height: 32),
                const Text(
                  'Admin Statistics',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        title: 'Total Admins',
                        value: '$totalAdmins',
                        icon: Icons.admin_panel_settings,
                        color: const Color(0xFF1976D2), // Blue
                        isPrimary: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        title: 'Active Admins',
                        value: '$activeAdmins',
                        icon: Icons.verified_user,
                        color: Colors.green,
                        isPrimary: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Empty space for alignment
                    const Expanded(child: SizedBox()),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  // Helper method to build stat cards
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isPrimary,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(isPrimary ? 0.5 : 0.3),
          width: isPrimary ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 32),
              if (isPrimary)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Primary',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
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

                        return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: CircleAvatar(
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
                      trailing: Row(
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
                    ),
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
              // Sort in-memory by timestamp (newest first) and limit to 100
              final logs = snapshot.data!.docs.where((doc) {
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

              // Limit to 100 most recent
              final limitedLogs = logs.take(100).toList();

              return ListView.builder(
                itemCount: limitedLogs.length,
                itemBuilder: (context, index) {
                  final log = limitedLogs[index].data() as Map<String, dynamic>;
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
              final admins = snapshot.data!.docs.toList()
                ..sort((a, b) {
                  final aTime = (a.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
                  final bTime = (b.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
                  if (aTime == null || bTime == null) return 0;
                  return bTime.compareTo(aTime); // Descending order
                });

              return ListView.builder(
                itemCount: admins.length,
                itemBuilder: (context, index) {
                  final admin = admins[index].data() as Map<String, dynamic>;
                  final adminId = admins[index].id;
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
