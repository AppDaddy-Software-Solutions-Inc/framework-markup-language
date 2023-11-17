// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'package:fml/datasources/http/http.dart';
import 'package:fml/hive/form.dart' as hive_pack;
import 'package:fml/hive/post.dart' as hive_pack;
import 'package:fml/observable/binding.dart';
import 'package:fml/observable/observables/boolean.dart';
import 'package:fml/observable/observables/integer.dart';
import 'package:fml/phrase.dart';
import 'package:fml/system.dart';
import 'package:fml/helpers/helpers.dart';

class PostMaster
{
  static final PostMaster _singleton = PostMaster._init();
  factory PostMaster()
  {
    return _singleton;
  }
  PostMaster._init();

  Timer? timer;
  int frequency   = 60;
  int maxattempts = 100;

  // busy 
  BooleanObservable? _busy;
  set busy(dynamic v)
  {
    if (_busy != null)
    {
      _busy!.set(v);
    }
    else if (v != null)
    {
      _busy = BooleanObservable(Binding.toKey("POSTMASTER", 'busy'), v, scope: System().scope, listener: System().onPropertyChange);
    }
  }
  bool get busy => _busy?.get() ?? false;
  

  // alerts 
  BooleanObservable? _alert;
  set alert(dynamic v) 
  {
    if (_alert != null) 
    {
      _alert!.set(v);
    } 
    else if (v != null) 
    {
      _alert = BooleanObservable(Binding.toKey("POSTMASTER", 'alert'), v, scope: System().scope, listener: System().onPropertyChange);
    }
  }
  bool get alert => _alert?.get() ?? false;

  // pending posts 
  IntegerObservable? _pending;
  set pending(dynamic v) 
  {
    if (_pending != null) 
    {
      _pending!.set(v);
    } 
    else if (v != null) 
    {
      _pending = IntegerObservable(Binding.toKey("POSTMASTER", 'pending'), v, scope: System().scope, listener: System().onPropertyChange);
    }
  }
  int get pending => _pending?.get() ?? 0;

  // errors 
  IntegerObservable? _errors;
  set errors(dynamic v) 
  {
    if (_errors != null) 
    {
      _errors!.set(v);
    } 
    else if (v != null) 
    {
      _errors = IntegerObservable(Binding.toKey("POSTMASTER", 'errors'), v, scope: System().scope, listener: System().onPropertyChange);
    }
  }
  int get errors => _errors?.get() ?? 0;
  
  Future<bool> start() async
  {
    // not in web
    if (isWeb) return true;
    bool ok = await _post();
    return ok;
  }

  Future<bool> stop() async
  {
    return true;
  }

  Future<bool> _post() async
  {
    if (!busy)
    {
      busy = true;

      if (timer != null) timer!.cancel();
      await _work();
      timer = Timer(Duration(seconds: frequency), _post);

      busy = false;
    }
    return true;
  }

  bool startNotified = false;

  Future<bool> _work() async
  {
    // Notify 
    if (!startNotified)
    {
      System.toast(phrase.postmasterPhrase001);
      startNotified = true;
    }

    // Get Incomplete Posts 
    List<hive_pack.Post> posts = await hive_pack.Post.query(where: "{status} == ${hive_pack.Post.statusINCOMPLETE}");

    // Sort Pending by Parent 
    posts.sort();

    // Set Pending Count 
    this.pending = posts;

    // Get Errors Count 
    List<hive_pack.Post> errors = await hive_pack.Post.query(where: "{status} == ${hive_pack.Post.statusERROR}");

    // Set Error Count 
    this.errors = errors;


      // Pending Count 
      int pending = posts.length;

      // Notify 
      if (pending > 0) System.toast(phrase.postmasterPhrase002.replaceAll("{jobs}", pending.toString()));

      // Clear Alert 
      alert = false;

      // Process Each Post 
      for (var post in posts) {
        if (await postable(post))
        {
          // Set Pending Count 
          this.pending = pending;

          // Post the Data 
          HttpResponse response = await Http.post(post.url!, post.body ?? '', headers: post.headers);

          // Error? 
          post.attempts = (post.attempts ?? 0) + 1;
          if (!response.ok)
          {
            if ((post.attempts ?? 0) > maxattempts) post.status   = hive_pack.Post.statusERROR;
            post.info = response.statusMessage;
            // bool ok   = (await post.update() == null);

            // Set Alert 
            alert = true;
          }

          // Ok 
          else
          {
            post.status = hive_pack.Post.statusCOMPLETE;
            // bool ok = (await post.update() == null);
            pending = pending - 1;
          }
        }
      }

    return true;
  }

  Future<bool> postable(hive_pack.Post post) async
  {
    if (!System().connected) return false;
    return await formPostable(post.formKey);
  }

  Future<bool> formPostable(String? key) async
  {
    // No Associated Form 
    if (isNullOrEmpty(key)) return true;

    // Lookup the Form 
    hive_pack.Form? form = await hive_pack.Form.find(key);

    // Form Not Found 
    if (form == null) return true;

    // Form Not Complete 
    if (!form.complete) return false;

    // Parent Postable? 
    return await formPostable(form.parent);
  }
}