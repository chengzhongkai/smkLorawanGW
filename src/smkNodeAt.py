#!/usr/bin/env python3
import serial
import time
import threading
import queue
import sys
from datetime import datetime

class SerCom:
    def __init__(self, tty, baud='9600'):
        self.ser = serial.Serial(tty, baud, timeout=0.1)
        self.queue = queue.Queue()

        self.event = threading.Event()
        self.thread_r = threading.Thread(target=self.recv_)
        self.thread_r.start()

    def recv_(self):
        while not self.event.is_set():
             line = self.ser.readline()
             if len(line) > 0:
                 print(str(datetime.now()) + ' < ' + str(line))
                 self.queue.put(line)

    def send(self, data):
        self.ser.write(data)

    def stop(self):
        self.event.set()
        self.thread_r.join()

print(sys.argv)

ser = SerCom('/dev/ttyUSB0', '9600')
if len(sys.argv) > 1:
    print(str(datetime.now()) + ' > ' + sys.argv[1])
    ser.send(sys.argv[1].encode()+b'\r')
else:
    ser.send(b'AT+TX=111111\r')
time.sleep(5)
ser.stop()

