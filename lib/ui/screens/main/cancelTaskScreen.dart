import 'package:flutter/material.dart';
import 'package:task_manager/ui/screens/main/updateTaskStatusBottomSheet.dart';

import '../../../data/model/networ_response.dart';
import '../../../data/model/summaryCountModel.dart';
import '../../../data/model/taskListModel.dart';
import '../../../data/services/networkCaller.dart';
import '../../../data/utils/urls.dart';

import '../../widgets/iteam_card.dart';
import '../../widgets/screenBackground.dart';
import '../../widgets/summary_card.dart';
import '../../widgets/taskListTile.dart';
import '../../widgets/userProfileBanner.dart';

class CancelTaskScreen extends StatefulWidget {
  const CancelTaskScreen({super.key});

  @override
  State<CancelTaskScreen> createState() => _CancelTaskScreenState();
}

class _CancelTaskScreenState extends State<CancelTaskScreen> {
  bool _getProgressTasksCancel = false;
  TaskListModel _taskListModel = TaskListModel();
  bool _getCountSummaryInProgress = false;
  SummaryCountModel _summaryCountModel = SummaryCountModel();

  Future<void> getCountSummary() async {
    _getCountSummaryInProgress = true;
    if (mounted) {
      setState(() {});
    }
    final NetworkResponse response =
    await NetworkCaller().getRequest(Urls.taskStatusCount);
    if (response.isSuccess) {
      _summaryCountModel = SummaryCountModel.fromJson(response.body!);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('get new task data failed')));
      }
    }
    _getCountSummaryInProgress = false;
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> getCancelProgressTasks() async {
    _getProgressTasksCancel = true;
    if (mounted) {
      setState(() {});
    }
    final NetworkResponse response =
        await NetworkCaller().getRequest(Urls.cancelTasks);
    if (response.isSuccess) {
      _taskListModel = TaskListModel.fromJson(response.body!);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cancelled tasks get failed')));
      }
    }
    _getProgressTasksCancel = false;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getCancelProgressTasks();
      getCountSummary();
    });
  }

  Future<void> deleteTask(String taskId) async {
    final NetworkResponse response =
        await NetworkCaller().getRequest(Urls.deleteTask(taskId));
    if (response.isSuccess) {
      _taskListModel.data!.removeWhere((element) => element.sId == taskId);
      if (mounted) {
        setState(() {});
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Deletion of task has been failed')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: ScreenBackground(
          child: Column(
            children: [
              const UserProfileBanner(),
              _getCountSummaryInProgress
                  ? const LinearProgressIndicator()
                  : Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 70,
                  width: double.infinity,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _summaryCountModel.data?.length ?? 0,
                    itemBuilder: (context, index) {
                      return SummeryCard(
                        title: _summaryCountModel.data![index].sId ?? 'New',
                        number: _summaryCountModel.data![index].sum ?? 0,
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return const Divider(
                        height: 4,
                      );
                    },
                  ),
                ),

              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    getCancelProgressTasks();
                    getCountSummary();
                  },
                  child: _getProgressTasksCancel
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : ListView.builder(
                          itemCount: _taskListModel.data?.length ?? 0,
                          itemBuilder: (context, index) {
                            return ItemCard(
                              child: TaskListTile(
                                data: _taskListModel.data![index],
                                onDeleteTab: () {
                                  deleteTask(_taskListModel.data![index].sId!);

                                },
                                onEditTab: () {
                                  showStatusUpdateBottomSheet(_taskListModel.data![index]);
                                },
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  void showStatusUpdateBottomSheet(TaskData task) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return UpdateTaskStatusSheet(task: task, onUpdate: () {
          getCancelProgressTasks();
        });
      },
    );
  }
}
