To create and deploy the Oracle Service Bus application blueprint, follow the steps in the OSB_blueprint.pdf.

Before starting with the steps in the OSB_blueprint.pdf, please download following versions of required software

(1) Oracle WebLogic Server 10.3.3
(2) Oracle Service Bus 11.1.1.3
(3) JDK 1.6.0 (this specific version required for OSB install)


and host it on a NFS server that is accessible in to the deployed VMs, and configure blueprint property 'DROPBOX_HOME' to this mount location on VMs.

Files: copy config directory, build.xml and runner.sh files under $DROPBOX_HOME/OSB folder. scripts used for install, configure & start actions can be found in the OSB_blueprint.pdf


