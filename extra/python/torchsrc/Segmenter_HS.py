import datetime
import os
import os.path as osp
import numpy as np
import pytz
import nibabel as nib
import torch
from torch.autograd import Variable
import tqdm

from utils.image_pool import ImagePool
import torchsrc

def mkdir(path):
    if not os.path.exists(path):
        os.makedirs(path)


class Segmenter(object):
    def __init__(self, cuda, model, optimizer,loss_fun,
                 test_loader,lmk_num,view,model_root_path,
                 out, max_epoch, network_num,batch_size,model_fname,
                 do_classification=True,do_landmarkdetect=True,
                 size_average=False, interval_validate=None,
                 compete = False,onlyEval=False):
        self.cuda = cuda
	self.model_fname = model_fname
        self.model = model
        self.optim = optimizer

        self.test_loader = test_loader
        self.model_root_path = model_root_path
        self.interval_validate = interval_validate
        self.network_num = network_num

        self.do_classification = do_classification
        self.do_landmarkdetect = do_landmarkdetect

        self.timestamp_start = \
            datetime.datetime.now(pytz.timezone('Asia/Tokyo'))
        self.size_average = size_average

        self.out = out
        if not osp.exists(self.out):
            os.makedirs(self.out)

        self.lmk_num = lmk_num
        #self.GAN = GAN
        self.onlyEval = onlyEval
        self.max_epoch = max_epoch
        self.epoch = 0
        self.iteration = 0
        self.best_mean_iu = 0

        self.compete = compete
        self.batch_size = batch_size
        self.view = view
        self.loss_fun = loss_fun

    def validate(self):
        self.model.train()
        out = osp.join(self.out, 'seg_output')
        results_epoch_dir = osp.join(out)
        mkdir(results_epoch_dir)

        prev_sub_name = 'start'
        prev_view_name = 'start'

        for batch_idx, (data,sub_name,view,img_name) in tqdm.tqdm(
                # enumerate(self.test_loader), total=len(self.test_loader),
                enumerate(self.test_loader), total=len(self.test_loader),
                desc='Valid epoch=%d' % self.epoch, ncols=80,
                leave=False):

            if self.cuda:
                data = data.cuda()
            data = Variable(data,volatile=True)

            pred = self.model(data)
            lbl_pred = pred.data.max(1)[1].cpu().numpy()[:,:, :]

            batch_num = lbl_pred.shape[0]
            for si in range(batch_num):
                curr_sub_name = sub_name[si]
                curr_view_name = view[si]
                curr_img_name = img_name[si]

                if prev_sub_name == 'start':
                    if lbl_pred.shape[1] == 256:
                        seg = np.zeros([256, 256, 1000], np.uint8)
                    else:
                        seg = np.zeros([512,512,512],np.uint8)
                    slice_num = 0
                elif not(prev_sub_name==curr_sub_name and prev_view_name==curr_view_name):
                    out_img_dir = os.path.join(results_epoch_dir, prev_sub_name)
                    mkdir(out_img_dir)
                    out_nii_file = os.path.join(out_img_dir,('%s_%s.nii.gz'%(prev_sub_name,prev_view_name)))
                    seg_img = nib.Nifti1Image(seg, affine=np.eye(4))
                    nib.save(seg_img, out_nii_file)
                    if lbl_pred.shape[1] == 256:
                        seg = np.zeros([256, 256, 1000], np.uint8)
                    else:
                        seg = np.zeros([512,512,512],np.uint8)
                    slice_num = 0

                test_slice_name = ('slice_%04d.png'%(slice_num+1))
                assert test_slice_name == curr_img_name
                seg_slice = lbl_pred[si, :, :].astype(np.uint8)
                if curr_view_name == 'view1':
                    seg[slice_num,:,:] = seg_slice
                elif curr_view_name == 'view2':
                    seg[:,slice_num,:] = seg_slice
                elif curr_view_name == 'view3':
                    seg[:, :, slice_num] = seg_slice

                slice_num+=1
                prev_sub_name = curr_sub_name
                prev_view_name = curr_view_name

        out_img_dir = os.path.join(results_epoch_dir, curr_sub_name)
        mkdir(out_img_dir)
        out_nii_file = os.path.join(out_img_dir, ('%s_%s.nii.gz' % (curr_sub_name, curr_view_name)))
        seg_img = nib.Nifti1Image(seg, affine=np.eye(4))
        nib.save(seg_img, out_nii_file)

    def segment_epoch(self):
        for epoch in tqdm.trange(self.epoch, self.max_epoch,
                                 desc='Train', ncols=80):
            self.epoch = epoch
            #model_fname = 'model_epoch_%04d.pth' % (epoch)
            model_fname = self.model_fname + '.pth'
            model_pth = os.path.join(self.model_root_path,self.view,model_fname)
            if self.cuda:
                self.model.load_state_dict(torch.load(model_pth))
            else:
                self.model.load_state_dict(torch.load(model_pth,map_location=lambda storage, loc: storage))
            self.validate()

