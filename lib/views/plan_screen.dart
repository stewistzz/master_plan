import 'package:master_plan/provider/plan_provider.dart';
import '../models/data_layer.dart';
import 'package:flutter/material.dart';

class PlanScreen extends StatefulWidget {
  final String planName; // Simpan hanya nama plan, bukan objek plan
  const PlanScreen({super.key, required this.planName});

  @override
  State createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  late ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController()
      ..addListener(() {
        FocusScope.of(context).requestFocus(FocusNode());
      });
  }

  @override
  Widget build(BuildContext context) {
    final plansNotifier = PlanProvider.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(widget.planName)),
      body: ValueListenableBuilder<List<Plan>>(
        valueListenable: plansNotifier,
        builder: (context, plans, child) {
          // Ambil plan terbaru dari provider, bukan dari widget.plan
          final currentPlan = plans.firstWhere(
            (p) => p.name == widget.planName,
            orElse: () => Plan(name: widget.planName, tasks: []),
          );

          return Column(
            children: [
              Expanded(child: _buildList(currentPlan, plansNotifier)),
              SafeArea(child: Text(currentPlan.completenessMessage)),
            ],
          );
        },
      ),
      floatingActionButton: _buildAddTaskButton(context),
    );
  }

  // _buildAddTaskButton tidak pakai plan lokal
  Widget _buildAddTaskButton(BuildContext context) {
    final planNotifier = PlanProvider.of(context);
    return FloatingActionButton(
      child: const Icon(Icons.add),
      onPressed: () {
        final plans = List<Plan>.from(planNotifier.value);
        final index = plans.indexWhere((p) => p.name == widget.planName);
        if (index == -1) return;

        final updatedTasks = List<Task>.from(plans[index].tasks)
          ..add(const Task());
        plans[index] = Plan(name: plans[index].name, tasks: updatedTasks);

        planNotifier.value = plans;
      },
    );
  }

  // Kirim plan dan notifier agar sinkron
  Widget _buildList(Plan plan, ValueNotifier<List<Plan>> planNotifier) {
    return ListView.builder(
      controller: scrollController,
      itemCount: plan.tasks.length,
      itemBuilder: (context, index) =>
          _buildTaskTile(plan, plan.tasks[index], index, planNotifier),
    );
  }

  Widget _buildTaskTile(
    Plan plan,
    Task task,
    int index,
    ValueNotifier<List<Plan>> planNotifier,
  ) {
    return ListTile(
      leading: Checkbox(
        value: task.complete,
        onChanged: (selected) {
          final plans = List<Plan>.from(planNotifier.value);
          final planIndex = plans.indexWhere((p) => p.name == plan.name);
          if (planIndex == -1) return;

          final updatedTasks = List<Task>.from(plan.tasks)
            ..[index] = Task(
              description: task.description,
              complete: selected ?? false,
            );

          plans[planIndex] = Plan(name: plan.name, tasks: updatedTasks);
          planNotifier.value = plans;
        },
      ),
      title: TextFormField(
        initialValue: task.description,
        onChanged: (text) {
          final plans = List<Plan>.from(planNotifier.value);
          final planIndex = plans.indexWhere((p) => p.name == plan.name);
          if (planIndex == -1) return;

          final updatedTasks = List<Task>.from(plan.tasks)
            ..[index] = Task(description: text, complete: task.complete);

          plans[planIndex] = Plan(name: plan.name, tasks: updatedTasks);
          planNotifier.value = plans;
        },
      ),
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}
