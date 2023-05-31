<html>
 <head>
  <title>{{ansible_os_family}} Application</title>
 </head>
 <body>
 </br>
  <a href=http://{{ ansible_default_ipv4.address }}/index.html>Homepage</a>
 </br>
<?php 
 Print "Hello, {{ansible_os_family}}"
?>
</body>
</html>
