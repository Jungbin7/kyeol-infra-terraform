# Bootstrap: 로컬 백엔드 (초기화용)
# Bootstrap은 자기 자신을 S3에 저장할 수 없으므로 로컬 사용
# jung-kyeol-bootstrap

terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

# 참고: Bootstrap 완료 후 다른 환경(dev/mgmt 등)은
# 이 Bootstrap에서 생성한 S3 버킷을 원격 백엔드로 사용합니다.
