<html>
    <head>
        <title>Hello World</title></head>
    <body style="background-image: linear-gradient(red,orange,yellow,green,blue,indigo,violet);">
        <center><img src="http://placekitten.com/800/600"></img></center>
        <marquee><h1>{{ test }} - {{ ansible_facts.default_ipv4.address }}</h1></marquee>
    </body>
</html>
