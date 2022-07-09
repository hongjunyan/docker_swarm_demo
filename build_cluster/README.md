# Use docker Swarm to Manage a Cluster

在這份筆記中，你將會學到如何透過docker swarm管理一個分散式系統的服務。流程一開始我以[multipass](https://multipass.run/) 在一台主機上模擬三台Ubuntu的node，
接著在這三台node分別安裝Docker Engine，這一步我將docker官方提供的安裝指令都整合進`./script/install_docker.sh`， 
來簡化安裝Docker的流程。值得注意的是，Docker Swarm已經整合在Docker Engine裡面，因此不需要再額外安裝任何套件。
在Docker Engine安裝完成後，我們將會任選一個node，在這個node上面初始化docker swarm，而該node就會被視作是Manager Node。
我們透過docker swarm的指令，將其餘的node分別加入docker swarm的管理中，形成一個cluster。最後我們就可以透過Manager node來執行我們的範例服務了。
Ok，整個流程大概到這邊，那我們就來一步一步地進行操作八。

## Step0 - Host Information
- OS: windows 10, 21H2
- RAM: 32GB
- CPU: i5-9400

## Step1 - Install VM node and Docker
- 安裝[multipass](https://multipass.run/)，接著開啟powershell並使用下方指令，創建三台Ubuntu20.04虛擬機，主機名稱分別是manager1，manager2, worker1，稍後我們會透過docker swarm建立兩個manger一個worker的cluster。
    ```
    $> multipass launch --name manager1
    $> multipass launch --name manager2
    $> multipass launch --name worker1
    ```


- 在每台虛擬機上安裝docker。我們要創建一個`install_docker.sh`檔案來幫助我們快速將docker安裝到三台虛擬需上。你可以直接複製下方的docker安裝指令，貼到`install_docker.sh`中，完成之後，我們就可以透過multipass的指令，將`install_docker.sh`傳送到每台虛擬機上，並執行腳本。
    - install_docker.sh
    ```bash
    # Set up the repository
    ## 1. Update the apt package index and install packages to allow apt to use a repository over HTTPS:
    sudo apt-get update
    sudo apt-get install -y \
        ca-certificates \
        curl \
        gnupg \
        lsb-release

    ## 2. Use the following command to set up the repository:
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    # 3. Install Docker Engine
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

    # 4. Restart docker
    sudo service docker stop && sudo service docker start

    # 5. Add your account to docker group
    sudo usermod -aG docker $USER
    ```
    - 傳送`install_docker.sh`到每台虛擬機上，並執行腳本
    ```bash
    # copy local install_docker.sh to the home folder of each VM
    $> multipass transfer ./install_docker.sh manager1:install_docker.sh
    $> multipass transfer ./install_docker.sh manager2:install_docker.sh
    $> multipass transfer ./install_docker.sh worker1:install_docker.sh

    # run install_docker.sh in each VM
    $> multipass exec manager1 -- bash install_docker.sh
    $> multipass exec manager2 -- bash install_docker.sh
    $> multipass exec worker1 -- bash install_docker.sh

    # check docker is running
    $> multipass exec manager1 -- docker version
    $> multipass exec manager2 -- docker version
    $> multipass exec worker1 -- docker version
    ```

## Step2 - Init Docker Swarm
在安裝完三台虛擬機(VM)後，我們可以透過`multipass ls`查看目前三台VM的網路配置情況。
<img src="imgs/multipass_ls.png" alt="Alt text" title="multipass ls"> \
接著我們選擇manager1 VM來初始化docker swarm，指令如下:
```bash
# login manager1 VM
$> multipass exec manager1 -- bash

# init docker swarm in manager1
ubuntu@manager1:$> export hostip=`ip addr | grep "eth0$" | sed 's/^.*inet //g' | sed 's/\/.* brd.*//g '`
ubuntu@manager1:$> echo $hostip
172.28.87.224
ubuntu@manager1:$> docker swarm init --advertise-addr $hostip

```
我們在manager1上面進行docker swarm的初始化，而docker swarm會將manager1當作為我們第一個"manager"的node。接著我們就可以根據`token`將其他node也加入到docker swarm中，形成一個cluster，其指令如下。
    
- 首先我們要先取得`token`
```bash
# get worker token
ubuntu@manager1:$> docker swarm join-token worker
To add a worker to this swarm, run the following command:
    
    docker swarm join --token SWMTKN-1-65oem57ricrz7aeccuazn8hvngih7t5dx2cetno4j66ud56444-djl8zhzacjm3b77rqpzajtl90 172.28.87.224:2377

# get manager token
ubuntu@manager1:$> docker swarm join-token manager
To add a manager to this swarm, run the following command:

    docker swarm join --token SWMTKN-1-65oem57ricrz7aeccuazn8hvngih7t5dx2cetno4j66ud56444-4s6o6buqswmwjwnm6tm0209hg 172.28.87.224:2377
```

- 透過上面得到的`token`，將manager2以manager身分加入docker swarm，
```bash
# login into manager2
$> multipass exec manager2 -- bash
ubuntu@manager2:$> docker swarm join --token SWMTKN-1-65oem57ricrz7aeccuazn8hvngih7t5dx2cetno4j66ud56444-4s6o6buqswmwjwnm6tm0209hg 172.28.87.224:2377
```

- 將worker1以worker身分加入docker swarm，
```bash
# login into worker1
$> multipass exec worker1 -- bash
ubuntu@worker1:$> docker swarm join --token SWMTKN-1-65oem57ricrz7aeccuazn8hvngih7t5dx2cetno4j66ud56444-djl8zhzacjm3b77rqpzajtl90 172.28.87.224:2377
```

- 登入manager1，使用`docker node ls`查看目前已經加入到cluster的nodes
<img src="imgs/docker_node_ls.png" alt="Alt text" title="multipass ls">

## Step3 - Assign Static IP on VMs
由於VM在每次重啟時都會隨機配置IP，而這會導致VM與Cluster失連。因此我們需要將Cluster裡面的VMs都設定成固定的IP。那我們就開始吧! 

首先，multipass是使用hyper的技術來啟動VM，因此我們先打開Hyper-V Manager，你可以透過windows的搜尋功能來找到Hyper-V Manager。 找到後，我們就開啟它\
<img src="imgs/hyperv_manager.png" alt="Alt text" title="multipass ls"> \
開啟後可以看到先前使用multipass架設的三個VM，我們點選manager1，接著在下方點擊Networking的tab，然後可以看到Connection是使用Default Switch。這代表manager1的網路數據是由Default Switch幫忙送到HOST，也因此Default Swtich的IP，就是manager1的network getway。這個getway IP會下一段設定VM的static IP時用上。
<img src="imgs/hyperv_manager_detail.png" alt="Alt text" title="multipass ls"> \

我們的VM是Ubuntu20.04，而在Ubuntu20.04上面設定static IP可以透過修改`/etc/netplan/50-cloud-init.yaml`來達成，請copy下方的內容到`50-cloud-init.yaml`，但要注意的是，`<VMIP>`要填入前面我們透過`multipass ls`得到VM IP，特別注意的是，Default Switch的netmask是255.255.240.0，因此在在VM IP後面要加上"/20"。在`<default_SWITCH_IP>`則是填入上一節得到的Default Wwitch IP。
```yaml
network:
  ethernets:
    eth0:
      dhcp4: false
      addresses: [<VMIP>/20]
      gateway4: <default_SWITCH_IP>
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4]
  version: 2
```
修改完成後執行`sudo netplan apply`，接著將剩下兩台VM都修改完，就大公告成了。

現在我們可以來檢驗，是否重啟VM後，HOST IP還是保持原本的，因此我們當前三來VM的IP紀錄在下方。
```bash
# Host IP Table
manager1: 172.28.87.224
manager2: 172.28.84.202
worker1: 172.28.88.195
```
檢查各個VM的IP跟上述IP TABLE紀錄的值是一致的，這邊以檢查manager1為例，我們先停止manager1的VM，接著透過multipass對manager1執行`ip addr`來查看IP是否和上面IP Table是一致的，如果不是的話，請檢察是否在設定static IP的步驟有出錯。
```
$> multipass stop manager1
$> multipass exec manager1 -- ip addr
```

## What's Next?
目前為止，我們已經透過docker swarm架設一個包含三個node的cluster，也為每個VM設定固定IP，確保這些VM不會在重啟時得到不同的IP，導致該VM與cluster失連。將服務佈署到cluster，就可以讓服務具有容錯性，因為當有一個node發生問題，服務會由另一台node接手。因此在下一篇文章，我們將會將python + redis的應用程式佈署到這個cluster，並試著關閉其中一個node，來觀察cluster對於錯誤發生，會採取的行為。