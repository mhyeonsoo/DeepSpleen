import os, sys
import argparse
import torch
import torch.nn as nn
import functools
import torchsrc
import generate_sublist
from img_loader_2labels import img_loader_2labels
import time

def mkdir(path):
    if not os.path.exists(path):
        os.makedirs(path)

def filter(subs,viewName):
	img_subs = []
	for i in range(len(subs)):
		if (subs[i][1]==viewName):
			img_subs.append(subs[i])
	return img_subs

start_time = time.time()
parser = argparse.ArgumentParser()
parser.add_argument('--model_name', help='model_spleen | model_whole')
parser.add_argument('--network', required=True,type=int,default=0, help='the network that been used')
parser.add_argument('--workers', type=int, help='number of data loading workers', default=1)
parser.add_argument('--batchSize_lmk', type=int, default=1, help='input batch size for lmk detection')
parser.add_argument('--lr', type=float, default=0.00001, help='learning rate, default=0.0001')
parser.add_argument('--augment',type=bool,default=False,help='True: do use augmented data')
parser.add_argument('--accreEval',type=bool,default=False,help='True: only evaluate accre results')
parser.add_argument('--viewName',help='viewall | view1 | view2 | view3')
parser.add_argument('--loss_fun',help='Dice | Dice_norm | cross_entropy')
parser.add_argument('--lmk_num',type=int, default=7, help='number of output channels')
opt = parser.parse_args()
print(opt)
# task_name = opt.task #0: do single task lmk, 1 do single task clss, 2 do multi task lmk, 3 do multi task lmk+clss
model_fname = opt.model_name # 0:'KidneyLong',1:'KidneyTrans',2:'LiverLong',3:'SpleenLong',4:'SpleenTrans'
start_epoch = 0
epoch_num = 1
lmk_batch_size = opt.batchSize_lmk
learning_rate = opt.lr
network_num = opt.network
num_workers = 4
augment = opt.augment
onlyEval = opt.accreEval
viewName = opt.viewName
lmk_num = opt.lmk_num
loss_fun = opt.loss_fun

code_path = os.getcwd()
fcn_torch_code_path = os.path.join(code_path, 'torchfcn')
if fcn_torch_code_path not in sys.path:
     sys.path.insert(0, fcn_torch_code_path)

#####################################################################################
#					  			Depends on the model you use
model_root_path = '/extra/deepNetworks/EssNet/500/cross_entropy/models'
# model_root_path = '/fs4/masi/hyeonsoo/models/EssNet/500/dice_norm/wholebody'
#####################################################################################
test_img_root_dir = '/OUTPUTS/Data_2D/'
working_root_dir = '/OUTPUTS/DeepSegResults/'

# For testing-in-local purpose
#model_root_path = '/share4/hyeonsoo/SegPipeline/docker_spleen/extra/deepNetworks/EssNet/500/cross_entropy/models'
#test_img_root_dir = '/share4/hyeonsoo/SegPipeline/docker_spleen/OUTPUTS/spatial_corrected/'
#working_root_dir = '/share4/hyeonsoo/SegPipeline/docker_spleen/OUTPUTS/DeepSegResults/'

# make the list of test and load test file processed
sublist_dir = os.path.join(working_root_dir,'sublist_test')
mkdir(sublist_dir)
test_img_list_file = os.path.join(sublist_dir,'test_list.txt')
test_subs = generate_sublist.dir2list(test_img_root_dir,test_img_list_file)
test_subs = generate_sublist.dir2list(test_img_root_dir,test_img_list_file)
test_set = img_loader_2labels(test_subs)
test_loader = torch.utils.data.DataLoader(test_set,batch_size=lmk_batch_size,shuffle=False,num_workers=num_workers)
#test_subs = generate_sublist.dir2list(test_img_root_dir,test_img_list_file)
onlyEval = True

# make output path
results_path = os.path.join(working_root_dir, 'results_single')
mkdir(results_path)
out = os.path.join(results_path,str(network_num),loss_fun)
mkdir(out)

##########################################################################################
#								Depends on the network being used
# for SSNet
model = torchsrc.models.FCNGCN(num_classes=lmk_num)

# # for ResNet9Blocks
# norm_layer = functools.partial(nn.InstanceNorm2d, affine=False)
# model = torchsrc.models.ResnetGenerator(input_nc=1, output_nc=lmk_num, ngf=64, norm_layer=norm_layer, use_dropout=False,n_blocks=9)


##########################################################################################

cuda = torch.cuda.is_available()
torch.manual_seed(1)
if cuda:
	torch.cuda.manual_seed(1)
	model = model.cuda()

optim = torch.optim.Adam(model.parameters(), lr = learning_rate, betas=(0.9, 0.999))

# Segmenter setting for segmentation
segmenter = torchsrc.Segmenter(
	cuda=cuda,
	model=model,
	optimizer=optim,
	test_loader=test_loader,
	out=out,
	network_num = network_num,
	max_epoch = epoch_num,
	model_fname = model_fname,
	batch_size = lmk_batch_size,
	lmk_num = lmk_num,
	onlyEval = onlyEval,
	view = viewName,
	model_root_path = model_root_path,
	loss_fun = loss_fun,
)


print("==start validation==")
print("==view is == %s "%viewName)

start_iteration = 1
segmenter.epoch = start_epoch
segmenter.iteration = start_iteration
segmenter.segment_epoch()
elapsed_time = time.time() - start_time
print("Elapsed time : %s"%elapsed_time)
