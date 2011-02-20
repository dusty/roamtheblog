$(document).ready(function(){
  $("#message p.notice, #message p.error").animate(
    {opacity: 1.0}, 3000).fadeOut("slow");

  $('a.delete').live('click', function(event) {
    $('<form method="post" action="' + this.href + '" />')
    .append('<input type="hidden" name="_method" value="delete" />')
    .appendTo('body')
    .submit();
    return false;
  });

  $('a.delete_prompt').live('click', function(event) {
    if (confirm($(this).attr('rel') || "Are you sure?")) {
      $('<form method="post" action="' + this.href + '" />')
      .append('<input type="hidden" name="_method" value="delete" />')
      .appendTo('body')
      .submit();
      return false;
    } else {
      return false;
    }
  });

  $('a.put').live('click', function(event) {
    $('<form method="post" action="' + this.href + '" />')
    .append('<input type="hidden" name="_method" value="put" />')
    .appendTo('body')
    .submit();
    return false;
  });

  $('a.put_prompt').live('click', function(event) {
    if (confirm($(this).attr('rel') || "Are you sure?")) {
      $('<form method="post" action="' + this.href + '" />')
      .append('<input type="hidden" name="_method" value="put" />')
      .appendTo('body')
      .submit();
      return false;
    } else {
      return false;
    }
  });

  $('a.post').live('click', function(event) {
    $('<form method="post" action="' + this.href + '" />')
    .append('<input type="hidden" name="_method" value="post" />')
    .appendTo('body')
    .submit();
    return false;
  });

  $('a.post_prompt').live('click', function(event) {
    if (confirm($(this).attr('rel') || "Are you sure?")) {
      $('<form method="post" action="' + this.href + '" />')
      .append('<input type="hidden" name="_method" value="post" />')
      .appendTo('body')
      .submit();
      return false;
    } else {
      return false;
    }
  });

  $('a.get_prompt').live('click', function(event) {
    if (confirm($(this).attr('rel') || "Are you sure?")) {
      return true;
    } else {
      return false;
    }
  });

});
