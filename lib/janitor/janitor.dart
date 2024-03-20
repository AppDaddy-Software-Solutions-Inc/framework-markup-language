// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'package:fml/hive/log.dart';
import 'package:fml/hive/form.dart';
import 'package:fml/hive/post.dart';
import 'package:fml/log/manager.dart' as log_manager;

/// The janitor service is used to cleanup old files
class Janitor {
  static final Janitor _singleton = Janitor._init();

  factory Janitor() => _singleton;
  Janitor._init();

  Timer? timer;

  // runtime frequency (seconds)
  int frequency = 60 * 10;

  // completed form retention (days)
  int formRetention = 10;

  // completed post retention (days)
  int postRetention = 1;

  bool busy = false;

  Future<bool> start() async => await _clean();

  Future<bool> stop() async => true;

  Future<bool> _clean() async {
    if (!busy) {
      busy = true;

      if (timer != null) timer!.cancel();
      await _doWork();
      timer = Timer(Duration(seconds: frequency), _clean);

      busy = false;
    }
    return true;
  }

  Future<bool> _doWork() async {
    // unix time
    int now = DateTime.now().millisecondsSinceEpoch;
    int millesecondsPerDay = 1000 * 60 * 60 * 24;

    // cleanup expired forms
    log_manager.Log().debug('Cleaning up old forms', caller: "Janitor");
    List<Form> forms = await Form.query();
    bool ok = true;
    for (var form in forms) {
      int age = form.updated;
      int delta = now - age;
      bool expired = ((delta / millesecondsPerDay) > formRetention);
      if (expired) {
        log_manager.Log().debug('Deleting form ${form.key}', caller: "Janitor");
        ok = (await form.delete() == null);
        if (ok) {
          log_manager.Log().info(
              'Deleting form and all associated posts. Form Key: ${form.key} - Complete: ${form.complete}',
              caller: 'Janitor');
        } else {
          log_manager.Log().warning(
              'Unable to delete form and possibly its associated posts. Form Key: $form.key, Complete: ${form.complete}',
              caller: 'Janitor');
        }
      }
    }

    // cleanup completed posts
    log_manager.Log()
        .debug('Cleaning up completed posting documents', caller: "Janitor");
    List<Post> posts =
        await Post.query(where: "{status} == ${Post.statusCOMPLETE}");
    for (var post in posts) {
      int age = post.date!;
      int delta = now - age;
      bool expired = ((delta / millesecondsPerDay) > postRetention);
      if (expired) {
        log_manager.Log()
            .debug('Deleting posting document ${post.key}', caller: "Janitor");
        ok = await post.delete();
        if (ok) {
          log_manager.Log().info(
              'Deleting completed post. Post Key: ${post.key}',
              caller: 'Janitor.dart');
        } else {
          log_manager.Log().warning(
              'Unable to delete completed post. Post Key: ${post.key}',
              caller: 'Janitor.dart');
        }
      }
    }

    // cleanup incomplete posts
    log_manager.Log().debug('Cleaning up old and incomplete posting documents',
        caller: "Janitor");
    posts = await Post.query();
    ok = true;
    for (var post in posts) {
      int age = post.date!;
      int delta = now - age;
      bool expired = ((delta / millesecondsPerDay) > formRetention);
      if (expired) {
        log_manager.Log()
            .debug('Deleting posting document ${post.key}', caller: "Janitor");
        ok = await post.delete();
        if (ok) {
          log_manager.Log().info(
              'Deleting incomplete post. Post Key: ${post.key}',
              caller: 'Janitor.dart');
        } else {
          log_manager.Log().warning(
              'Unable to delete uncompleted post. Post Key: ${post.key}',
              caller: 'Janitor.dart');
        }
      }
    }

    // cleanup logs
    log_manager.Log().debug('Cleaning up old log files', caller: "Janitor");
    List<Log> logs = await Log.findAll();
    for (var log in logs) {
      int keepFor = DateTime.now()
          .subtract(const Duration(days: Log.daysToSave))
          .toLocal()
          .millisecondsSinceEpoch;
      if (keepFor > log.epoch) log.delete();
    }

    return true;
  }
}
