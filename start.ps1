# start.ps1
# �w�q�e���M�M���ɦW��
$IMAGE_NAME = "youtube-dl-webui"
$CONTAINER_NAME = "youtube-dl-container"

# 定義專�??��?
$PROJECT_DIR = (Get-Item .).FullName

# �ˬd�e���O�_�w�g�s�b�ùB��A�p�G�����ܡA������ò���
$existingContainers = docker ps -a --filter "name=$CONTAINER_NAME" --format "{{.ID}}"
if ($existingContainers) {
    Write-Host "Stopping and removing existing container: $CONTAINER_NAME"
    docker stop $CONTAINER_NAME | Out-Null
    docker rm $CONTAINER_NAME | Out-Null
}

# �إ� Docker �M����
Write-Host "Building Docker image: $IMAGE_NAME"
docker build -t $IMAGE_NAME $PROJECT_DIR

# �ˬd�M���ɬO�_�إߦ��\
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Docker image build failed."
    exit 1
}

# 設�?下�??��???Windows 路�?
# 請�??�裡?�路徑修?�為你�?實�? Windows 下�?路�?
# ���ˬd�A�� start.ps1 �}��
# ��� docker run ���O�������A�T�O���O�o�˼g���G

# �]�w�U���ؿ��� Windows ���|
$DOWNLOAD_PATH = "D:\_TEMP"

# �Ұʷs���e��
Write-Host "Starting new container: $CONTAINER_NAME"
docker run -d `
    --name $CONTAINER_NAME `
    -p 5000:5000 `
    --mount type=bind,source="$DOWNLOAD_PATH",target="/app/downloads" `
    --restart unless-stopped `
    $IMAGE_NAME