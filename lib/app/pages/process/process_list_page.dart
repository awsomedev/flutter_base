import 'package:flutter/material.dart';
import '../../models/process_model.dart';
import '../../services/services.dart';
import '../../app_essentials/colors.dart';
import 'create_process_page.dart';

class ProcessListPage extends StatefulWidget {
  const ProcessListPage({Key? key}) : super(key: key);

  @override
  State<ProcessListPage> createState() => _ProcessListPageState();
}

class _ProcessListPageState extends State<ProcessListPage> {
  List<Process> processes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProcesses();
  }

  Future<void> fetchProcesses() async {
    try {
      final processList = await Services().getProcesses();
      if (mounted) {
        setState(() {
          processes = processList;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Widget _buildProcessCard(Process process) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      color: AppColors.surface,
      child: Column(
        children: [
          ExpansionTile(
            title: Text(
              process.name ?? '',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (process.description != null) ...[
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        process.description!,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                    if (process.nameMal != null ||
                        process.descriptionMal != null) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Malayalam',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (process.nameMal != null)
                        Text(
                          process.nameMal!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      if (process.descriptionMal != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          process.descriptionMal!,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 1),
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateProcessPage(
                          process: process,
                        ),
                      ),
                    );
                    if (result == true) {
                      fetchProcesses();
                    }
                  },
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 20,
                    color: AppColors.primary,
                  ),
                  label: const Text(
                    'Edit',
                    style: TextStyle(
                      color: AppColors.primary,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              Container(
                width: 1,
                height: 24,
                color: AppColors.divider,
              ),
              Expanded(
                child: TextButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Process'),
                        content: Text(
                          'Are you sure you want to delete ${process.name}?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              try {
                                Navigator.pop(context);
                                if (process.id != null) {
                                  await Services().deleteProcess(process.id!);
                                }
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Process deleted successfully'),
                                      backgroundColor: AppColors.success,
                                    ),
                                  );
                                  fetchProcesses();
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                          Text('Failed to delete process: $e'),
                                      backgroundColor: AppColors.error,
                                    ),
                                  );
                                }
                              }
                            },
                            child: const Text(
                              'Delete',
                              style: TextStyle(color: AppColors.error),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: AppColors.error,
                  ),
                  label: const Text(
                    'Delete',
                    style: TextStyle(
                      color: AppColors.error,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Processes',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        centerTitle: true,
        backgroundColor: AppColors.surface,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: processes.length,
              itemBuilder: (context, index) =>
                  _buildProcessCard(processes[index]),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateProcessPage(),
            ),
          );
          if (result == true) {
            fetchProcesses();
          }
        },
        backgroundColor: AppColors.primary,
        child: const Icon(
          Icons.add,
          color: AppColors.background,
        ),
      ),
    );
  }
}
