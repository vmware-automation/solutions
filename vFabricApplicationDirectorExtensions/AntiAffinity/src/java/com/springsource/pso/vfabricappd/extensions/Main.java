/*
 * A Java Application connecting to vCenter and creating (anti-) affinity rules
 * Useful as a task in vFabric Application Director or elsewhere
 * Written by Emil A. Siemes (esiemes@vmware.com)
 */

package com.springsource.pso.vfabricappd.extensions;

import java.net.MalformedURLException;
import java.net.URL;
import com.vmware.vim25.*;
import com.vmware.vim25.mo.*;

import java.rmi.RemoteException;
import java.util.HashSet;
import java.util.Properties;
import java.util.StringTokenizer;
import com.vmware.vim25.mo.HostSystem;
import com.vmware.vim25.mo.ServiceInstance;
import com.vmware.vim25.mo.VirtualMachine;

public class Main {
	private final static String USERARG = "-u", PASSWDARG = "-p",
			VCENTERARG = "-v", IPSARG = "-ips", RULEARG = "-r",
			RULENAME = "-n";

	private static ServiceInstance si;

	public static void main(String[] args) throws Exception {

		/*
		 * Read command line arguments and put them into a properties object for
		 * easy retrieval Format always: -nameOfArgument value, last argument
		 * does not need to have a name e.g. -n "foo" "other argument" is valid
		 */
		Properties props = new Properties();
		for (int i = 0; i < args.length - 1; i += 2) {
			if (i >= args.length - 3 && args.length % 2 == 1)
				continue;
			if (args[i].charAt(0) == '-') {
				props.put(args[i], args[i + 1]);
			}
		}

		/*
		 * Verify we have all args we need. Print usage if not
		 */
		boolean allArgsSet = false;
		if (props.containsKey(RULEARG) && props.containsKey(USERARG)
				&& props.containsKey(VCENTERARG) && props.containsKey(IPSARG))
			allArgsSet = true;
		
		if (!allArgsSet || props.size() != 6) {
			System.err
					.println("Usage: "
							+ new Main().getClass().getName()
							+ " "
							+ RULEARG
							+ " \"antiaffinity|affinity\" "
							+ RULENAME
							+ " \"Name of the rule\" "
							+ USERARG
							+ " \"vCenter User\" "
							+ PASSWDARG
							+ " \"vCenter Password\" "
							+ VCENTERARG
							+ " \"vCenter hostname|ip address\" "
							+ IPSARG
							+ " \"comma seperated list of ip addresses for the vms the rule should be applied to\"");
			return;
		}
		/*
		 * All args in. Let's procede
		 */
		String RULETYPE = props.getProperty("-r");
		String VCENTERUSER = props.getProperty("-u");
		String VCENTERPASSWD = props.getProperty("-p");
		String VCENTERHOST = props.getProperty("-v");
		String VCENTERURL = "https://" + VCENTERHOST + "/sdk";
		String RULENAME = props.getProperty("-n");
		String IPS = props.getProperty("-ips");

		boolean success= createRule(VCENTERURL, VCENTERUSER, VCENTERPASSWD, IPS, RULETYPE,
				RULENAME);
		if(success)
			System.exit(0);
		System.exit(1);
	}

	public static boolean createRule(String vcenter, String user,
			String password, String vmips, String ruletype, String rulename) {
		/*
		 * First connect to vCenter with provided credentials
		 */
		System.err.println("Connecting to: " + vcenter + " as " + user);
		System.err.println("Creating rule for: " + vmips);

		try {
			si = new ServiceInstance(new URL(vcenter), user, password, true);
		} catch (RemoteException e1) {
			System.err.println("Can not connect to vCenter: " + vcenter
					+ " using " + user + "/" + password);
			return false;
		} catch (MalformedURLException e1) {
			e1.printStackTrace();
			return false;
		}

		if ("antiaffinity".equals(ruletype) || "affinity".equals(ruletype)) {
			/*
			 * First digest all ip addresses. # They are comma seperated and
			 * they could also come in the format ["ip1", "ipN"] through
			 * Application Director We are getting rid of the extra characters
			 * through the clean method Adding individual ip addresses to a
			 * HashSet
			 */
			StringTokenizer st = new StringTokenizer(vmips, ",");
			/*
			 * We have st.countTokens() number of ip addresses and we need to
			 * retrieve the VMs they belong to later
			 */
			VirtualMachine vms[] = new VirtualMachine[st.countTokens()];
			HashSet<String> ips = new HashSet<String>(vms.length);
			while (st.hasMoreTokens()) {
				String ip = st.nextToken();
				ip = clean(ip);
				// System.out.println("adding: " + ip);
				ips.add(ip);
			}

			int nvms = 0;

			try {
				/*
				 * Get all VMs
				 */
				ManagedEntity[] mes = new InventoryNavigator(si.getRootFolder())
						.searchManagedEntities("VirtualMachine");
				if (mes == null || mes.length == 0) {
					return false;
				}
				String clusterName = "";
				/*
				 * Iterate through all VMs
				 */
				for (int i = 0; i < mes.length; i++) {
					VirtualMachine vm = (VirtualMachine) mes[i];
					/*
					 * Sanity check
					 */
					if (vm == null || vm.getGuest() == null
							|| vm.getGuest().getIpAddress() == null)
						continue;
					/*
					 * Test wether this VM has a matching ip address
					 */
					if (ips.contains(vm.getGuest().getIpAddress())) {
						/*
						 * If this is the first VM with matching ip address
						 * let's figure out the name of the cluster it belongs
						 * to We iterate through all HostSystem and check to
						 * which one our VM belongs. If we have got the
						 * HostSystem (ESXi) the cluster is the parent of the
						 * HostSystem
						 */
						if (nvms == 0) {
							ManagedEntity[] mes2 = new InventoryNavigator(
									si.getRootFolder())
									.searchManagedEntities("HostSystem");
							HostSystem hs = null;
							for (int h = 0; h < mes2.length; h++) {
								hs = (HostSystem) mes2[h];
								VirtualMachine hvms[] = hs.getVms();
								for (int v = 0; v < hvms.length; v++) {
									if (hvms[v].getName().equals(vm.getName())) {
										clusterName = hs.getParent().getName();
									}
								}
							}
						}
						/*
						 * ip address matches, remember VM
						 */
						vms[nvms++] = vm;
					} else {
					}

				}
				/*
				 * Sanity check: If the number of matching vms is not equal to
				 * the length of the vm array which is of length
				 * st.countTokens() (number of ip addresses) something stinks
				 */
				if (nvms != vms.length) {
					System.err.println("Can not find all or some vms with ip: "
							+ ips + " " + nvms);
					return false;
				}

				/*
				 * Now as we know the name of the cluster let's retrieve the
				 * cluster object
				 */
				mes = new InventoryNavigator(si.getRootFolder())
						.searchManagedEntities("ClusterComputeResource");
				ClusterComputeResource ccr = null;
				for (int i = 0; i < mes.length; i++) {
					ClusterComputeResource c = (ClusterComputeResource) mes[i];
					if (c.getName().equals(clusterName)) {
						ccr = c;
					}
				}

				/*
				 * Sanity check: ccr should never be null.
				 */
				if (ccr == null) {
					System.err.println("Can not find cluster: " + clusterName);
					return false;
				}

				/*
				 * Optional: Do nothing if rule name exists already Rule names
				 * do not necessarily have to be unique. vCenter distinguishes
				 * them by id
				 * 
				 * ClusterRuleInfo rules[]= ccr.getConfiguration().getRule();
				 * for(int i= 0; i< rules.length; i++) {
				 * if(rules[i].getName().equals(rulename)) return; }
				 */

				/*
				 * Let's create the rule now
				 */
				ClusterRuleInfo cri = null;
				if ("antiaffinity".equals(ruletype))
					cri = new ClusterAntiAffinityRuleSpec();
				else
					cri = new ClusterAffinityRuleSpec();
				cri.setName(rulename);
				cri.setEnabled(Boolean.TRUE);

				/*
				 * Let's add the the VM's ManagedObjectReferences to the rule
				 */
				ManagedObjectReference vmMORs[] = new ManagedObjectReference[vms.length];
				for (int i = 0; i < vms.length; i++) {
					vmMORs[i] = createMOR("VirtualMachine", vms[i].getMOR()
							.getVal());

				}
				if ("antiaffinity".equals(ruletype))
					((ClusterAntiAffinityRuleSpec) cri).setVm(vmMORs);
				else
					((ClusterAffinityRuleSpec) cri).setVm(vmMORs);

				/*
				 * Now adding the new rule to the cluster
				 */
				ClusterRuleSpec crs = new ClusterRuleSpec();
				crs.setOperation(ArrayUpdateOperation.add);
				crs.setInfo(cri);

				ClusterConfigSpec ccs = new ClusterConfigSpec();
				ccs.setRulesSpec(new ClusterRuleSpec[] { crs });

				/*
				 * Reconfigure cluser, logout and we're all set
				 */
				ccr.reconfigureCluster_Task(ccs, true);
				si.getServerConnection().logout();
				System.err.println("Done setting rule: "+rulename+" for cluster: "+clusterName);
			} catch (Exception e) {
				e.printStackTrace();
				return false;
			}
		}
		return true;
	}

	private static String clean(String ip) {
		StringBuffer in = new StringBuffer(ip);
		StringBuffer ret = new StringBuffer();
		for (int i = 0; i < in.length(); i++) {
			char c = in.charAt(i);
			if (c != '[' && c != ']' && c != '"')
				ret.append(c);
		}
		return ret.toString();
	}

	private static ManagedObjectReference createMOR(String type, String id) {
		ManagedObjectReference mor = new ManagedObjectReference();
		mor.setType(type);
		mor.set_value(id);
		return mor;
	}

}
