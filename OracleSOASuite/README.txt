To create and deploy the Oracle SOA suite application blueprint, follow the steps in the SOA_Blueprint.pdf.

Before starting with the steps in the SOA_Blueprint.pdf, please download following versions of required software

(1)	Oracle SOA Suite 10g on the app tier
(2)	Oracle Database 11.2.0.2 on the database tier
(3)	JDK 1.6.0


and host it on a NFS server that is accessible in to the deployed VMs, and configure blueprint property 'DROPBOX_HOME' to this mount location on VMs.

Files: copy scripts folder and other files to $DROPBOX_HOME/SOACLONE folder. scripts used for install, configure & start actions can be found in the SOA_Blueprint.pdf


