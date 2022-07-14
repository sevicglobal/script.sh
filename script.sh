if [ $# -ne 1 ]; then
  echo "Usage"
  echo "$ bash eic-cli.sh i-1234"
  exit 1
fi

instance_id=$1

# get EC2 data
availability_zone=$(aws ec2 describe-instances --instance-ids $instance_id | jq -r .Reservations[0].Instances[0].Placement.AvailabilityZone)
ip_address=$(aws ec2 describe-instances --instance-ids $instance_id | jq -r .Reservations[0].Instances[0].PublicIpAddress)

# generate RSA key pair
tmpfile=$(mktemp /tmp/ssh.XXXXXX)
ssh-keygen -C "eic temp key" -q -f $tmpfile -t rsa -b 2048 -N ""
public_key=${tmpfile}.pub
private_key=$tmpfile

# register public key
aws ec2-instance-connect send-ssh-public-key \
  --instance-id  $instance_id \
  --instance-os-user ec2-user \
  --ssh-public-key file://$public_key \
