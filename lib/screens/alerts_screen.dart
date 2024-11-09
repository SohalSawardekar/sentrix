// TODO Implement this library.
import 'package:flutter/material.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  final List<Map<String, dynamic>> _alertTypes = [
    {
      'type': 'Price',
      'icon': Icons.attach_money,
      'description': 'Alert when price crosses threshold'
    },
    {
      'type': 'Sentiment',
      'icon': Icons.trending_up,
      'description': 'Alert on significant sentiment changes'
    },
    {
      'type': 'Volume',
      'icon': Icons.show_chart,
      'description': 'Alert on unusual trading volume'
    },
    {
      'type': 'News',
      'icon': Icons.newspaper,
      'description': 'Alert on breaking news'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Alerts & Notifications'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Active Alerts'),
              Tab(text: 'Alert History'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildActiveAlerts(),
            _buildAlertHistory(),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _showCreateAlertBottomSheet,
          icon: const Icon(Icons.add_alert),
          label: const Text('New Alert'),
        ),
      ),
    );
  }

  Widget _buildActiveAlerts() {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: 5, // Replace with actual alerts
      itemBuilder: (context, index) {
        return Card(
          elevation: 2,
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.notifications_active,
                color: Theme.of(context).primaryColor,
              ),
            ),
            title: Text('AAPL Price Alert'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Trigger: Above \$150'),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.circle,
                      size: 12,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 4),
                    Text('Active'),
                  ],
                ),
              ],
            ),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Text('Edit Alert'),
                ),
                const PopupMenuItem(
                  value: 'pause',
                  child: Text('Pause Alert'),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Text(
                    'Delete Alert',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
              onSelected: _handleAlertAction,
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  Widget _buildAlertHistory() {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: 10, // Replace with actual history
      itemBuilder: (context, index) {
        return Card(
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.history),
            ),
            title: Text('TSLA Sentiment Alert'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Major sentiment shift detected'),
                Text(
                  '2 hours ago',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => _showAlertDetails(index),
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  void _showCreateAlertBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Create New Alert',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _alertTypes.length,
                  itemBuilder: (context, index) {
                    final alertType = _alertTypes[index];
                    return Card(
                      child: ListTile(
                        leading: Icon(alertType['icon'] as IconData),
                        title: Text(alertType['type'] as String),
                        subtitle: Text(alertType['description'] as String),
                        onTap: () => _showAlertConfigurationDialog(alertType),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAlertConfigurationDialog(Map<String, dynamic> alertType) {
    Navigator.pop(context); // Close bottom sheet
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Configure ${alertType['type']} Alert'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Symbol',
                  hintText: 'Enter stock symbol (e.g., AAPL)',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Threshold',
                  hintText: 'Enter trigger threshold',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Trigger Condition',
                ),
                items: const [
                  DropdownMenuItem(value: 'above', child: Text('Above')),
                  DropdownMenuItem(value: 'below', child: Text('Below')),
                  DropdownMenuItem(value: 'change', child: Text('% Change')),
                ],
                onChanged: (value) {},
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Save alert logic here
              Navigator.pop(context);
              _showSuccessSnackBar();
            },
            child: const Text('Create Alert'),
          ),
        ],
      ),
    );
  }

  void _handleAlertAction(String action) {
    switch (action) {
      case 'edit':
        // Show edit dialog
        break;
      case 'pause':
        // Pause alert logic
        break;
      case 'delete':
        _showDeleteConfirmation();
        break;
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Alert'),
        content: const Text('Are you sure you want to delete this alert?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Delete alert logic
              Navigator.pop(context);
              _showSuccessSnackBar('Alert deleted successfully');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAlertDetails(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alert Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Type', 'Sentiment Alert'),
            _buildDetailRow('Symbol', 'TSLA'),
            _buildDetailRow('Triggered', '2 hours ago'),
            _buildDetailRow('Sentiment Change', '+25%'),
            _buildDetailRow('Source', 'Multiple news articles'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }

  void _showSuccessSnackBar([String message = 'Alert created successfully']) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Dismiss',
          onPressed: () {},
        ),
      ),
    );
  }
}
