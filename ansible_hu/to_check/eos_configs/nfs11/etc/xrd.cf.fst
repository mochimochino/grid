###########################################################
set MGM=grid04.aligrid.hiroshima-u.ac.jp
###########################################################

###########################################################
set myName = Hiroshima
all.sitename ALICE::Hiroshima::EOS

xrootd.fslib -2 libXrdEosFst.so
xrootd.async off nosf
xrd.network keepalive
xrootd.redirect $(MGM):1094 chksum

# Specify when threads are created, how many can be created, and when they should be destroyed.
# https://xrootd.web.cern.ch/doc/dev57/xrd_config.htm#_Toc171719950
xrd.sched mint 16 avlt 24 idle 60 maxt 512

# Set timeout parameters for incoming connections
# https://xrootd.web.cern.ch/doc/dev57/xrd_config.htm#_Toc171719953
xrd.timeout hail 30 kill 10 read 20 idle 600

###########################################################
xrootd.seclib libXrdSec.so
sec.protocol unix
sec.protocol sss -c /etc/eos.keytab -s /etc/eos.keytab
sec.protbind * only unix sss

###########################################################
all.export / nolock
all.trace none
all.manager localhost 2131
#ofs.trace open

###########################################################
xrd.port 1095
ofs.persist off
ofs.osslib libEosFstOss.so
ofs.tpc pgm /opt/eos/xrootd/bin/xrdcp

###########################################################
# this URL can be overwritten by EOS_BROKER_URL defined /etc/sysconfig/xrd
fstofs.broker root://grid04.hiroshima-u.ac.jp:1097//eos/
fstofs.autoboot true
fstofs.quotainterval 10
fstofs.metalog /var/eos/md/
#fstofs.authdir /var/eos/auth/
#fstofs.trace client
###########################################################

# QuarkDB cluster info needed by FSCK to perform the namespace scan
fstofs.qdbcluster grid04.aligrid.hiroshima-u.ac.jp:7777,grid05.aligrid.hiroshima-u.ac.jp:7777,grid06.aligrid.hiroshima-u.ac.jp:7777
fstofs.qdbpassword_file /etc/quarkdb.pass

# Use gRPC?
#fstofs.protowfusegrpc true

fstofs.filemd_handler attr

#-------------------------------------------------------------------------------
# Configuration for XrdHttp http(s) service
#-------------------------------------------------------------------------------
if exec xrootd
    xrd.protocol XrdHttp:8001 libXrdHttp.so
    http.exthandler EosFstHttp /usr/lib64/libEosFstHttp.so none
    http.trace  false

    # HOST CERTS REQUIRED
    http.exthandler  xrdtpc libXrdHttpTPC.so
    xrd.tls  /etc/grid-security/hostcert.pem /etc/grid-security/hostkey.pem
    xrd.tlsca  certdir /etc/grid-security/certificates/
fi

#xrootd.monitor all flush 60s window 30s dest files info user file:/var/log/eos/mgm/xrdmon.log
xrootd.monitor all auth flush 30s window 5s info level all dest vobox.your.domain:9930

