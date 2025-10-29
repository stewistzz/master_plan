/// membuat model plan yang berisi nama dan daftar tugas

import './task.dart';

class Plan {
  final String name;
  final List<Task> tasks;

  const Plan({this.name = '', this.tasks = const []});
}
