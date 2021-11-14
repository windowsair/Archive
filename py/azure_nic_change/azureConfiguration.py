from menu import Menu
import jsonlines
from azureChangeIP.mgmt.resource import ResourceManagementClient
from azureChangeIP.common.credentials import ServicePrincipalCredentials
from azureChangeIP.mgmt.network import NetworkManagementClient
from azureChangeIP.mgmt.compute import ComputeManagementClient
# TODO: auto fill login config

"""
Fill your config here 
"""

# use `az ad sp create-for-rbac --sdk-auth > mycredentials.json`
# to get config file and fill this
config_credentials = ServicePrincipalCredentials(
    client_id='4ca05656-1a6e-4853-811d-b167d23a8fbc',
    secret='7daf07cd-21f2-4059-a6d2-6d7b8571fdbf',
    tenant='607c3bb4-b3e0-4394-800f-e4ccc5403ce8'
)
config_ResourceGroupName = 'HK'
# https://azure.microsoft.com/en-us/global-infrastructure/locations/
# find your location here
# may be like this 'East Asia'
config_Location = 'East Asia'
config_SubscriptionId = 'a5642f9e-2f59-4d9b-8992-9f23d53f71ec'
config_NIC_Name = 'test541'
config_VirtualNetworks_Name = 'HK-vnet'


# TODO: style...
class AzureOperation(object):
    def __init__(self):
        self.resourceClient = ResourceManagementClient(config_credentials, config_SubscriptionId)
        self.networkClient = NetworkManagementClient(config_credentials, config_SubscriptionId)
        self.computeClient = ComputeManagementClient(config_credentials, config_SubscriptionId)

        self.resourceGroups = self.resourceGroups if hasattr(self, "resourceGroups") else []
        self.subscriptionId = config_SubscriptionId
        self.vmList = []
        self.virtualNetworkList = []
        self.ipConfigurations = []

        self.resourceGroupSelected = None
        self.virtualMachineSelected = None
        self.networkInterfaceSelected = None  # may be like this '.../networkInterfaces/test541'
        self.virtualNetworkSelected = None
        self.nicDetail = None
        self.subnetSelected = None
        self.primaryIP = None

    def getResourceGroupList(self):
        self.resourceGroups = self.resourceClient.resource_groups.list()
        self.resourceGroups = list(self.resourceGroups)
        return self.resourceGroups
        # self.resourceGroups[0].name

    def listVmFromResourceGroup(self, resourceGroupSelected=None):
        if resourceGroupSelected:
            self.vmList = self.computeClient.virtual_machines.list(resourceGroupSelected)
        else:
            self.vmList = self.computeClient.virtual_machines.list(self.resourceGroupSelected)
        self.vmList = list(self.vmList)
        return self.vmList

    def getVnetFromNIC(self, resourceGroupSelected=None, networkInterfaceSelected=None):
        if networkInterfaceSelected and resourceGroupSelected:
            self.virtualNetworkList = self.networkClient.subnets.list(resourceGroupSelected, networkInterfaceSelected)
        else:
            self.virtualNetworkList = self.networkClient.subnets.list(self.resourceGroupSelected,
                                                                      self.networkInterfaceSelected)
        self.virtualNetworkList = list(self.virtualNetworkList)
        return self.virtualNetworkList

    # get ip config here...
    def getNicInformation(self, resourceGroupSelected=None, networkInterfaceSelected=None):
        if networkInterfaceSelected and resourceGroupSelected:
            self.nicDetail = self.networkClient.network_interfaces.get(resourceGroupSelected, networkInterfaceSelected)
        else:
            self.nicDetail = self.networkClient.network_interfaces.get(self.resourceGroupSelected,
                                                                       self.networkInterfaceSelected)
        self.ipConfigurations = self.nicDetail.ip_configurations
        return self.nicDetail

    def getPublicIpAddressInformation(self, resourceGroupSelected, publicIpAddressName):
        if resourceGroupSelected and publicIpAddressName:
            return self.networkClient.public_ip_addresses.get(resourceGroupSelected, publicIpAddressName)
        else:
            raise RuntimeError("Resource group name and public ip address name is required.")

    def getSubnetInformation(self, resourceGroupSelected, virtualNetworkName, subnetName):
        if not resourceGroupSelected and virtualNetworkName and subnetName:
            raise RuntimeError("Resource group name and virtual network name and subnet name is required.")
        return self.networkClient.subnets.get(resourceGroupSelected, virtualNetworkName, subnetName)

    def test2(self):
        return self.networkClient.subnets.list_all()
    # primary main NIC in VM
    #

    def test3(self):
        return self.networkClient.public_ip_prefixes.list_all()

    def test4(self):  # 一个例子展示了怎么添加特定的ip
        ### 这个丢给ip_configurations 字段
        ax = {
                    'name': 'test123',
                    'private_ip_allocation_method': 'Dynamic',
                    'primary': False,
                    'subnet': {
                        'id': '/subscriptions/a5642f9e-2f59-4d9b-8992-9f23d53f71ec/resourceGroups/HK/providers/Microsoft.Network/virtualNetworks/HK-vnet/subnets/default'
                    },
                    'public_ip_address': {
                        'id': '/subscriptions/a5642f9e-2f59-4d9b-8992-9f23d53f71ec/resourceGroups/HK/providers/Microsoft.Network/publicIPAddresses/azure-sample-publicip'
                    }

        }
        # TODO: 找到subnet 以及 public_ip_address的 id
        self.ipconfig.append(ax)

        return self.networkClient.network_interfaces.create_or_update(
            'HK',
            'test541',
            {
                'location': config_Location,
                'ip_configurations': self.ipconfig
            }
        )

    def addIp(self):  # 创建一个公网ip
        self.networkClient.public_ip_addresses.create_or_update(
            'HK', 'azure-sample-publicip2',
            {'location': config_Location,
             'public_ip_allocation_method': 'Static',
             }
        )


# TODO: menu ...
class UserExample(AzureOperation):
    def __init__(self):
        super().__init__()
        self.menu_option_resource_group = []
        self.menu_option_virtual_machine = []
        self.menu_option_network_interface = []
        self.menu_option_ip_configuration = []
        self.menu_option_public_ip_address_detail = []
        self.main_menu = Menu(
            title="====== Main Menu ======",
            message="Choose resource group to continue:",
            refresh=self.checkResourceGroup,
            prompt="Enter the number to continue >"
        )
        self.virtual_machine_menu = Menu(
            title="====== Virtual Machine ======",
            message="Choose virtual machine to continue:",
            prompt="Enter the number to continue >"
        )
        self.network_interface_menu = Menu(
            title="====== Network Interface ======",
            message="Choose network interface to continue:",
            prompt="Enter the number to continue >"
        )
        self.ip_configuration_menu = Menu(
            title="====== IP Configuration ======",
            message="Choose ip configuration to see more details.\n" +
                    "We will inherit the subnet settings of your chosen ip configuration.\n" +
                    "IP config name    / public ip address resource name / subnet",
            prompt="Enter the number to continue >"
        )
        self.public_ip_address_detail_menu = Menu(
            title="====== Public IP Address ======",
            message="",  # To show more ip detail...
            prompt="Enter the number to continue >"
        )

    def checkResourceGroup(self):
        if len(self.resourceGroups) is 0:
            if self.getResourceGroupList():
                self.menu_option_resource_group = []
                for resource_group in self.resourceGroups:
                    self.menu_option_resource_group.append(
                        (resource_group.name, self.findVm, {"name": resource_group.name})
                    )
                self.menu_option_resource_group.append(
                    ("Exit", Menu.CLOSE)
                )
                self.main_menu.set_options(self.menu_option_resource_group)
            else:
                print("Resource group not found.Exit.")
                exit()
        else:
            self.main_menu.set_options(self.menu_option_resource_group)

    def findVm(self, name=None):
        if not name:
            raise RuntimeError("Wrong resource group name.")
        self.resourceGroupSelected = name
        print("Selected resource group : %s" % name)
        self.listVmFromResourceGroup()
        # change to new menu
        if len(self.vmList) is not 0:
            self.menu_option_virtual_machine = []
            for vm in self.vmList:
                self.menu_option_virtual_machine.append(
                    (vm.name, self.findNetworkInterface, {"vmSelected": vm})
                )
            self.menu_option_virtual_machine.append(
                ("Back", self.virtual_machine_menu.close)
            )
        else:
            self.menu_option_virtual_machine = [
                ("Not find virtual machine.Back.", self.virtual_machine_menu.close)
            ]
        self.virtual_machine_menu.set_options(self.menu_option_virtual_machine)
        self.virtual_machine_menu.open()

    def findNetworkInterface(self, vmSelected=None):
        if not vmSelected:
            raise RuntimeError("No virtual machine selected.")
        self.virtualMachineSelected = vmSelected
        # self.vmList[0].network_profile.network_interfaces[0].id
        self.menu_option_network_interface = []
        for networkInterface in vmSelected.network_profile.network_interfaces:
            self.menu_option_network_interface.append(
                (networkInterface.id.split('/')[-1],
                 self.getIpConfigurations, {"networkInterfaceSelected": networkInterface.id})
            )
        self.menu_option_network_interface.append(
            ("Back", self.network_interface_menu.close)
        )

        self.network_interface_menu.set_options(self.menu_option_network_interface)
        self.network_interface_menu.open()

    # TODO: find all sub-net
    def getIpConfigurations(self, networkInterfaceSelected=None):
        if not networkInterfaceSelected:
            raise RuntimeError("No network interface selected.")
        self.networkInterfaceSelected = networkInterfaceSelected
        self.getNicInformation(self.resourceGroupSelected, networkInterfaceSelected.split('/')[-1])
        self.menu_option_ip_configuration = []
        for ip_config in self.ipConfigurations:
            hasIpAddress__ = hasattr(ip_config.public_ip_address, 'id')
            # set primary ip
            if ip_config.primary:
                ipInformation__ = self.getPublicIpAddressInformation(self.resourceGroupSelected, ip_config.public_ip_address.id.split('/')[-1])
                self.primaryIP = ipInformation__.ip_address
            self.menu_option_ip_configuration.append(
                (ip_config.name + (" (primary)     " if ip_config.primary else "     ") +
                 (ip_config.public_ip_address.id.split('/')[-1] if hasIpAddress__ else "None") +
                 "     " + ip_config.subnet.id.split('/')[-1],
                 self.showIpDetails, {'ipSelected': ip_config, 'hasIpAddress': hasIpAddress__})
            )
        self.menu_option_ip_configuration.append(
            ("Back", self.ip_configuration_menu.close)
        )
        self.ip_configuration_menu.set_options(self.menu_option_ip_configuration)
        self.ip_configuration_menu.open()
        """
               ip_config.public_ip_address # 相关的公网ip指定
                ip_config.subnet # 子网络设置
                ip_config.primary # 最基本的ip配置
        """

    def showIpDetails(self, ipSelected: None, hasIpAddress: False):
        if not ipSelected:
            raise RuntimeError("No ip selected.")
        if hasIpAddress:
            public_ip__ = self.getPublicIpAddressInformation(self.resourceGroupSelected,
                                                             ipSelected.public_ip_address.id.split('/')[-1])
        subnet__ = self.getSubnetInformation(self.resourceGroupSelected,
                                             ipSelected.subnet.id.split('/')[-3],
                                             ipSelected.subnet.id.split('/')[-1])
        self.subnetSelected = subnet__.id
        # subnet__.id  子网的id
        # public_ip__.id 公网ip的 id
        # id may like this '.../virtualNetworks/xxx-vnet/subnets/default'
        show_message__ = "===============\n" + \
            "Name: %s\n" % (public_ip__.name if hasIpAddress else "(no ip address yet)") + \
            "Location: %s\n" % (public_ip__.location if hasIpAddress else "(no ip address yet)") + \
            "IP Address: %s\n" % (public_ip__.ip_address if hasIpAddress else "None") + \
            "Subnet name : %s\n" % subnet__.name + \
            "Subnet Address prefix: %s\n" % subnet__.address_prefix + \
            "\n===============\nWe will inherit the subnet settings of your chosen ip configuration.\n" + \
            "Now type 1 to continue or 2 to back and reset."

        self.public_ip_address_detail_menu.set_message(show_message__)
        self.menu_option_public_ip_address_detail = [
            ("Continue", self.confirmConfig),
            ("Back", self.public_ip_address_detail_menu.close)
        ]
        self.public_ip_address_detail_menu.set_options(self.menu_option_public_ip_address_detail)
        self.public_ip_address_detail_menu.open()

    def confirmConfig(self):
        self.saveConfig()
        print("====================\nDone\n====================")
        self.main_menu.open()

    def saveConfig(self):
        configuration_json__ = {
            'configuration':
                {
                    'subscription_id': '',
                    'resource_group_name': '',
                    'virtual_machine': '',
                    'network_interface': '',
                    'subnet_id': '',
                    'primary_ip': ''
                }
        }
        configuration_json__['configuration']['subscription_id'] = self.subscriptionId
        configuration_json__['configuration']['resource_group_name'] = self.resourceGroupSelected
        configuration_json__['configuration']['virtual_machine'] = self.virtualMachineSelected.id.split('/')[-1]
        configuration_json__['configuration']['network_interface'] = self.networkInterfaceSelected.split('/')[-1]
        configuration_json__['configuration']['subnet_id'] = self.subnetSelected.split('/')[-3]  # may be like this 'xxx-vnet/subnets/default'
        configuration_json__['configuration']['primary_ip'] = self.primaryIP
        with jsonlines.open('./config.jsonl', 'a') as writer:
            writer.write(configuration_json__)
            writer.close()

    def run(self):
        self.main_menu.open()


if __name__ == '__main__':
    app = UserExample()
    app.addIp()
