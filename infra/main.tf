resource "aws_vpc" "main_vpc" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "Mario_vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "Mario-igw"
  }
}

resource "aws_subnet" "public_subnet" {
  count = length(var.public_subnet_cidr_block)
  vpc_id = aws_vpc.main_vpc.id
  availability_zone = var.availability_zone[count.index]
  cidr_block = var.public_subnet_cidr_block[count.index]
  map_public_ip_on_launch = true

  tags = {
   Name = "Public_subnet_mario-${count.index +1}"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "mario-public-route-table"
  }
}

resource "aws_route" "igw-rta" {
  route_table_id = aws_route_table.public_rt.id
  gateway_id = aws_internet_gateway.igw.id
  destination_cidr_block = "0.0.0.0/0"

}

resource "aws_route_table_association" "public_rta" {
  count = length(var.public_subnet_cidr_block)
  route_table_id = aws_route_table.public_rt.id
  subnet_id = aws_subnet.public_subnet[count.index].id
}


resource "aws_eip" "my_eip" {
  domain = "vpc"

  tags = {
   Name = "mario-eip"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.my_eip.id
  subnet_id = aws_subnet.public_subnet[0].id
  
  tags = {
    Name = "Mario_nat"
  }
  
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
   Name = "mario_rt"
  }
}

resource "aws_subnet" "private_subnet" {
  count = length(var.private_subnet_cidr_block)
  vpc_id = aws_vpc.main_vpc.id
  cidr_block = var.private_subnet_cidr_block[count.index]
  availability_zone = var.availability_zone[count.index]

 tags = {
   Name = "mario_private_rt"
  }
}

resource "aws_route" "private_route" {
  nat_gateway_id = aws_nat_gateway.nat.id
  route_table_id = aws_route_table.private_rt.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "private_rta" {
  count = length(var.private_subnet_cidr_block)
  subnet_id = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_iam_role" "eks_role" {
  name = "eks_cluster_role"
  assume_role_policy = jsonencode ({
    Version = "2012-10-17"
    Statement = [
       {
        Action = "sts:AssumeRole"
        Principal = {
           Service = "eks.amazonaws.com"
        }
        Effect = "Allow"
       }
     ]
  })
}
  
resource "aws_iam_role_policy_attachment" "eks_policy" {
  role = aws_iam_role.eks_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role" "eks_node_role" {
  name = "eks_node_role"
  assume_role_policy = jsonencode ({
    Version = "2012-10-17"
    Statement = [
       {
        Action = "sts:AssumeRole"
        Principal = {
            Service = "ec2.amazonaws.com"
        }
        Effect = "Allow"
       }
     ]
  })
}

resource "aws_iam_role_policy_attachment" "worker_node_policy" {
  role = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "cni_policy" {
  role = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "registery_read_only_policy" {
  role = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_eks_cluster" "mario_cluster" {
  name = var.project_name
  role_arn = aws_iam_role.eks_role.arn

  vpc_config {
    subnet_ids = aws_subnet.public_subnet[*].id
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_policy
  ]

  tags = {
    Name = "Mario_eks_cluster"
  }
}

output "eks_cluster_name" {
  value = "aws_eks_cluster.mario_cluster.name"
}

resource "aws_eks_node_group" "mario_nodes" {
  cluster_name = aws_eks_cluster.mario_cluster.name
  node_role_arn = aws_iam_role.eks_node_role.arn
  subnet_ids = aws_subnet.private_subnet[*].id
  instance_types = [var.instance_type]
  scaling_config {
    desired_size = 2
    max_size = 3
    min_size = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.worker_node_policy,
    aws_iam_role_policy_attachment.cni_policy,
    aws_iam_role_policy_attachment.registery_read_only_policy
  ]
  
  tags = {
    Name = "Mario_nodes"
  }
}
