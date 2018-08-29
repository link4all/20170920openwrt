#!/usr/bin/haserl
content-type: text/html



<html>
<meta charset="UTF-8">
<body>
<h1>Sample Form</h1>


          <form action="apsta_re.asp" method="post">
          <p>SSID: <input type="text" name="ssid" /></p>
          <p>Channel: <input type="text" name="channel" /></p>
          <p>Password: <input type="text" name="passwd" /></p>
          <input type="submit" value="Submit" />
          </form>
          
          <form action="play_re.asp" method="post">
          <p>Radio ID: <input type="text" name="radioid" /></p>
          <input type="submit" value="Submit" />
          </form>
          
           <form action="setvol_re.asp" method="post">
          <p>Volume[0-127]: <input type="text" name="vol" /></p>
          <input type="submit" value="Submit" />
          </form>
          <p>
    <p> 
    <%     
    current=$(cat /www/current);
    total=$(wc -l /www/radio.txt |cut -d" " -f1);
    id=$(sed -n "${current}p" /www/radio.txt );
    id_next=$(sed -n "$((${current}+1))p" /www/radio.txt );
    id_pre=$(sed -n "$((${current}-1))p" /www/radio.txt );
    echo "current is: ${current}<br />";
    echo "current id is: ${id} <br />";
    echo "next id is: ${id_next} <br />";
    echo "previous id is: ${id_pre}<br /><br />";
    echo "total radio list are: ${total} <br />";

    kk=$((${current}+1));
    #echo ${kk};
  
    echo "<a href=\"/play_re.asp?radioid=${id_next}&play=next\">Play Next</a><br />";
    echo "<a href=\"/play_re.asp?radioid=${id_pre}&play=pre\">Play Previous</a><br />";
    echo "<a href=\"/play_re.asp?play=stop\">stop</a><br />";
    %>
    </p>
          电台id示例：<br />
"CNR中国之声"|386<br />
"安徽交通广播"|1949<br />
"厦门电台94私家车"|1741<br />
"福州人民广播电台左海之声"|3937<br />
"FM881音乐之声"|5021731<br />
"海峡之声闽南语广播"|1746<br />
"厦门892集美广播"|5022479<br />
"985平潭共同家园广播"|20523<br />
"德化人民广播电台"|3881<br />
"江西交通广播"|1811<br />
"江西新闻广播"|1809<br />
"怀集音乐之声"|4804<br />
"青苹果音乐台"|4576<br />
"清晨音乐台"|4915<br />
"K歌电台"|5022347<br />
"AsiaFM亚洲音乐台"|4581<br />
"中国豫剧广播"|20509<br />
"床伴FM-失眠电台"|5022349<br />
          
          </p>

</body>
</html>



