function [errPerm, Freqs] = peak_det_mse( freq, amp, target, bounds_inds)
% This function detects peak amplitudes in the spectrum based on however
% many targets you give it
lowfbound_ind = bounds_inds(1);
highfbound_ind = bounds_inds(2);
freq = freq(lowfbound_ind:highfbound_ind);
amp = amp(lowfbound_ind:highfbound_ind);

[Y, I]=sort(amp); % Sort amplitudes along with indices
IndexFreq= I((end-length(target)+1):end); % Retrieves the top n = length(target) amplitude indices
Freqs = round(freq(IndexFreq),2); % Finds corresponding freqs for top amplitude indices
permFreqs = perms(Freqs); % The amplitudes are less relevant, so look at all possible orderings based on amp
targets = repmat(target,length(target),1);
errs = round(permFreqs - targets,6);
errs_mse= mean((errs).^2,2);
errPerm = min(errs_mse); % Returns the error for the most accurate permutation
end

%% trash
% SortTarget=sort(target);
%errSort = (SortTarget-freq(IndexFreq)).^2/length(target);
% SubtractMat=zeros(length(target));
% for Ti = 1:length(target)
%     for Fi = 1:length(target)
%         SubtractMat(Ti,Fi) = SortTarget(Ti) - round(freq(IndexFreq(Fi)),2);
%     end
% end
% SubtractMat = round(SubtractMat,2);
% err1 = mean(diag(SubtractMat).^2);
% err2 = mean(diag(SubtractMat).^2);
% for i=1:length(IndexFreq)
%     fi = round(freq(IndexFreq(i)),2)
%     SubtractMat=[SubtractMat, SortTarget-fi];
% end
% 
% SubtractMat=SubtractMat';
% SubtractMat=reshape(SubtractMat',length(target),length(target)); reshape
% will generate column wise mat that's why the diagnal is just flipped 
% errSort1= mean(SubtractMat(1:length(target)+1:end).^2);
% errSort2= mean(SubtractMat(1:length(target)+1:end).^2);
% errPerm = mean(SubtractMat.^2);