---
title: Instrumentation
last_updated: 2015-11-18
---

## Available Instrumentation Options

### Rails

In Rails applications, we use ActiveSupport::Notifications to track the following.

* Controller Actions
* Controller File Sending
* View Collection Rendering
* View Partial Rendering
* View Template Rendering
* View Layout Rendering
* ActiveRecord SQL Queries
* ActiveSupport Cache

### Grape

* Endpoint Execution
* Endpoint Filters
* Endpoint Rendering

### Sinatra

* Endpoint Execution

### Net::HTTP

* HTTP Requests

### Excon

* HTTP Requests

### Tilt

* Template Rendering

### Redis

* All Commands

> NOTE: We do not instrument AUTH as it would include sensitive data.

### Sequel

* SQL Queries

### Moped/Mongoid

* MongoDB Queries (Currently only 4.x, 5.x coming soon)


## How it Works

If you're curious about how our instrumentation works, you're in the right place.

### Normalizers

Our preferred method of instrumentation is [`ActiveSupport::Notifications`](http://api.rubyonrails.org/classes/ActiveSupport/Notifications.html) events. When a library has added instrumentation, all we need to do is subscribe to the event and do a little bit of normalization of the data.

To standardize this process, we introduced `Normalizers`. Each type of instrumenation has its own normalizer which handles the, well, normalization. You can take a look at some of them [in the source](https://github.com/skylightio/skylight-ruby/tree/master/lib/skylight/normalizers).

### Probes

While we think most libraries should include `ActiveSupport::Notifications` (anyone can subscribe to these notifications, not just Skylight), unfortunately, many still don't. In these circumstances, we have to carefully monkey-patch the libraries at their key points.

To make sure we do this in a sane fashion, we developed `Probes`. Probes are small classes that keep an eye out for specific modules and then hook into them when they're loaded. All probes can be disabled in the event of any conflicts and we only autoload probes that we have a high degree of confidence in.

And, since we don't really like having to moneky-patch things either, when at all possible, we [submit pull requests](https://github.com/ruby-grape/grape/pull/1086) to relevant projects to add in ActiveSupport::Notifications.


## Instrumenting a Library

## Custom App Instrumentation

The easiest way to add custom instrumentation to your application is by
specifying methods to instrument, but it is also possible to instrument
specific blocks of code.

### Method instrumentation

Instrumenting a specific method will cause an event to be created every time
that method is called. The event will be inserted at the appropriate place in
the Skylight trace.

To instrument a method, the first thing to do is include `Skylight::Helpers`
into the class that you will be instrumenting. Then, annotate each method that
you wish to instrument with `instrument_method`.

~~~ ruby
class MyClass
  include Skylight::Helpers

  instrument_method
  def my_method
    do_expensive_stuff
  end

end
~~~

You may also declare the methods to instrument at any time by passing the name
of the method as the first argument to `instrument_method`.

~~~ ruby
class MyClass
  include Skylight::Helpers

  def my_method
    do_expensive_stuff
  end

  instrument_method :my_method

end
~~~

By default, the event will be titled using the name of the class and the
method. For example, in our previous example, the event name will be:
`MyClass#my_method`. You can customize this by passing using the **:title** option.

~~~ ruby
class MyClass
  include Skylight::Helpers

  instrument_method title: 'Expensive work'
  def my_method
    do_expensive_stuff
  end
end
~~~

### Block instrumentation

If more fine-grained instrumentation is required, you may use the block instrumenter.

~~~ ruby
class MyClass
  def my_method
    Skylight.instrument do
      step_one
      step_two
    end
    step_three
  end
end
~~~

Just like above, the title of the event can be configured with the **:title** option.


> It's important that the title of the event is the same for all requests that
> hit the code path. Skylight aggregates traces using the title. You should
> pass a string literal and not use any interpolation. Otherwise, there will be
> an explosion of nodes that show up in your aggregate Skylight trace.

~~~ ruby
class MyClass
  def my_method
    Skylight.instrument title: "Doin' stuff" do
      step_one
      step_two
    end
    step_three
  end
end
~~~