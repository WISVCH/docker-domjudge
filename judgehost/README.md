By running build.sh an image for installing extra languages on the default docker image including the chroot. 

By setting the enverioment variables in the Dockerfile you can add Python2, Mono and Kotlin.

## Judgehost crashing on TLE for kotlin

The judgehost crashes when a  kotlin program is executed with time limit exceeded. For example for the default problem hello, submitting

```kotlin
fun main() {
  val input = readLine()!!
  while(true);
  println("Hello world!")
}
```
Will crash the domjudge since a defunct(zombie) process is still running once the killguard tries to kill it. Example output of the judgedeamon:
```log
[Jun 10 17:46:54.942] judgedaemon[34]: Judge started on judgehost-0 [DOMjudge/7.2.1]
[Jun 10 17:46:54.946] judgedaemon[34]: executing chroot script: 'chroot-startstop.sh check'
[Jun 10 17:46:54.947] judgedaemon[34]: Registering judgehost on endpoint default: http://domserver/api/v4
[Jun 10 17:46:55.102] judgedaemon[34]: Found unfinished judging j11 in my name; given back
[Jun 10 17:46:55.365] judgedaemon[34]: No submissions in queue (for endpoint default), waiting...
[Jun 10 18:04:05.313] judgedaemon[34]: Judging submission s2 (endpoint default) (t1/p1/kt), id j12...
[Jun 10 18:04:05.920] judgedaemon[34]: Working directory: /opt/domjudge/judgehost/judgings/judgehost-0/endpoint-default/2/2/12
[Jun 10 18:04:06.040] judgedaemon[34]: Fetching new executable 'kt'
[Jun 10 18:04:10.674] judgedaemon[34]: executing chroot script: 'chroot-startstop.sh start'
[Jun 10 18:04:17.223] testcase_run.sh[488]: error: found processes still running as 'domjudge-run-0', check manually:
    247 java <defunct>
[Jun 10 18:04:17.236] judgedaemon[34]: error: Unknown exitcode from testcase_run.sh for s2, testcase 1: 127
```

Further investigation lead to the following process chain:
```log
root@judgehost:/# ps -ejf | grep k
domjudg+     236     235     236     236  0 18:04 ?        00:00:00 bash /usr/bin/kotlin -Dfile.encoding=UTF-8 -J-XX:+UseSerialGC -J-Xss65536k -J-Xms1966080k -J-Xmx1966080k HelloKt
domjudg+     237     236     236     236  0 18:04 ?        00:00:00 bash /usr/bin/kotlinc -Dfile.encoding=UTF-8 -J-XX:+UseSerialGC -J-Xss65536k -J-Xms1966080k -J-Xmx1966080k HelloKt
domjudg+     247     237     236     236 36 18:04 ?        00:00:00 java -Xmx256M -Xms32M -Dfile.encoding=UTF-8 -XX:+UseSerialGC -Xss65536k -Xms1966080k -Xmx1966080k -Dkotlin.home=/usr/local/lib/kotlinc -cp /usr/local/lib/kotlinc/lib/kotlin-runner.jar org.jetbrains.kotlin.runner.Main HelloKt
root         260     102     259     102  0 18:04 pts/0    00:00:00 grep k
```

The kotlin and kotlinc scripts are properly killed, but the java process remains. 

### workaround
By not using the kotlin wrapper, but rewritting the code to a direct java call will make runguard kill the process properly.

By going into executable > kt > view file contents > run tab and edit the file.

look for the line:
```shell script
exec kotlin -Dfile.encoding=UTF-8 -J-XX:+UseSerialGC -J-Xss${MEMSTACK}k -J-Xms${MEMLIMITJAVA}k -J-Xmx${MEMLIMITJAVA}k '$MAINCLASS' "\$@"
```

and replace it with(make sure the paths for kotlin home and the kotlin runner jar are correct for your installation):
```shell script
exec java -Dfile.encoding=UTF-8 -XX:+UseSerialGC -Xss${MEMSTACK}k -Xms${MEMLIMITJAVA}k -Xmx${MEMLIMITJAVA}k -Dkotlin.home=/usr/local/lib/kotlinc -cp /usr/local/lib/kotlinc/lib/kotlin-runner.jar org.jetbrains.kotlin.runner.Main '$MAINCLASS' "\$@"
```

