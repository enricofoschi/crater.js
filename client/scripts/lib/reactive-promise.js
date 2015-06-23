this.ReactivePromise = function() {

    var _tasks = {};

    // the current task completion status
    var ready = function(task) {
        return _tasks[task].get();
    };

    // a handle object that can be used with Iron Router waitOn
    var getHandle = function(task) {
        return {
            "task": task,
            "ready": function() {
                return ready(task);
            }
        }
    }

    // register a new task to be monitored
    var when = function(task) {

        check(task, String);
        _tasks[task] = new ReactiveVar(false);
        var promises = _.chain(arguments).toArray().rest().flatten().value();

        $.when.apply($, promises).always(function() {
            _tasks[task].set(true);
        });

        return getHandle(task);

    };

    // template helper for conditional template rendering
    Template.registerHelper("isReactivePromiseReady", function(task) {
        return ready(task);
    });

    return {
        "when": when,
        "getHandle": getHandle,
        "ready": ready,
    };

}();