module "vpc" {
  source = "./modules/vpc"
  instance_id = module.ec2.instance_id
}

module "sg" {
  source = "./modules/sg"
  vpc_id = module.vpc.vpc_id
}

module "ec2" {
  source = "./modules/ec2"
  private_subent1 = module.vpc.private_subent1
  security_group = module.sg.security_group
  public_subnet = module.vpc.public_subnet1
  bastion_host_sg = module.sg.bastion_host_sg
}