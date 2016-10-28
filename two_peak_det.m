clear
clc
close all

%% two oscillation's frequency parameters
oscCenter1 = 10.54; % hard coded 
oscCenter2 = 10.56; % hard coded
sampleRate = 1000; % hard coded
nyq = sampleRate/2;
sampleSpacing = 1/sampleRate;
phaseOffsets = 0:(pi/6):2*pi; % hard coded
dataLengthGens = 1:11; % hard coded, 11 data lengths
dataLengthSecs = (0.05*2.^dataLengthGens); % in seconds hard coded
% plot(dataLengths, 'o')
nfft = 100*sampleRate;

%% Run params
run_fft = 1;
run_welch = 0;

%% FFT
if run_fft
	dataLength_errors = [];
	dataLength_rts = [];
	for dataLengthSec = dataLengthSecs;
		phaseOffset_errors = [];
		phaseOffset_rts = [];
		for phaseOffset = phaseOffsets;
			dataLengthSamples = dataLengthSec*sampleRate;
			[osc1,t] = chan_osc(dataLengthSamples, sampleRate,oscCenter1,'phaseOffset',phaseOffset, 'isNoisy', 1, 'snr', 10);
			osc2 = chan_osc(dataLengthSamples, sampleRate,oscCenter2);
			data = osc1+osc2;
			plot(data)
			fft_freqs = linspace(0,nyq,floor(nfft/2)+1);

			tic
			dataX = fft(data,nfft)/dataLengthSamples;
			dataX = dataX(1:length(fft_freqs)); %keep only positive frequencies
			phaseOffset_rt = toc;
			amp = 2*abs(dataX);
			phaseOffset_error = peak_det_mse(fft_freqs,amp,[oscCenter1,oscCenter2]);

			phaseOffset_errors = [phaseOffset_errors phaseOffset_error];
			phaseOffset_rts = [phaseOffset_rts phaseOffset_rt];

			    plot(fft_freqs,2*abs(dataX))
% 			    xlim([10.5 10.56])
			    ylabel('Amplitude')
			    title(['Data Length = ', num2str(dataLengthSec),' sec'])
			%     pause(0.5)
		end

		% (length(dataLength_errors)) x (length(phaseOffsets)) matrix
		dataLength_errors = [dataLength_errors; phaseOffset_errors];
		dataLength_rts = [dataLength_rts; phaseOffset_rts];
	end

	save('fft_errors.mat','dataLength_errors');
	save('fft_rts.mat','dataLength_rts');

	%%
	close all
	figure;
	plot(dataLengthSecs,max(dataLength_errors,[],2)./0.0002); % for each datalength, what's the maximum error over phaseoffsets
	title('FFT')
	figure;
	plot(dataLengthSecs,max(dataLength_rts,[],2)); % for each datalength, what's the maximum runtime over phaseoffsets
	figure;
	plot(phaseOffsets,dataLength_errors'); % plots errors over phaseOffsets for each dataLength
end

%% Welch
if run_welch
	% figure;
	dataLength_errors = []; % length is equal to length(welch_dls)
	dataLength_rts = []; % length is equal to length(welch_dls)
	nfft = 100*sampleRate; %hard coded
	windowLengthPercs = (10:10:70)./100;
	overlapPercs = (10:10:70)./100;
	% For each data length 11
		% For each windowlength 7
			% For each nOverlap 7
				% For each phaseoffset 13
				% Store error for each phaseoffset
			% Store error for each nOverlap
		% Store error for each windowlength
	% Store error for data length

	for dataLengthSecs = dataLengthSecs % defined for all methods at the top
		dataLengthSamples = dataLengthSecs*sampleRate
		windowLength_errors = []; % length equal to length(dls_wls)
		windowLength_rts = []; % length equal to length(dls_wls)
		windowLengthsSamples = windowLengthPercs*dataLengthSamples;

		for windowLengthSamples = windowLengthsSamples;
			phaseOffset_errors = [];
			phaseOffset_rts = [];
			nOverlaps = overlapPercs.*windowLengthSamples;
			for phaseOffset = phaseOffsets % defined for all methods at the top
				nOverlap_errors = [];
				nOverlap_rts = [];
				osc1 = chan_osc(dataLengthSamples, sampleRate,oscCenter1,'phaseOffset',phaseOffset);
				osc2 = chan_osc(dataLengthSamples, sampleRate,oscCenter2);
				data = osc1+osc2;
				for nOverlap = nOverlaps
					tic
					[pow, welch_f] = pwelch(data,windowLengthSamples,nOverlap,nfft,sampleRate, 'power', 'onesided');
					nOverlap_rt = toc;
					amp = sqrt(pow);
					nOverlap_error = peak_det_mse(welch_f,amp,[oscCenter1,oscCenter2]);
					nOverlap_errors = [nOverlap_errors nOverlap_error];
					nOverlap_rts= [nOverlap_rts nOverlap_rt];
				end
				phaseOffset_errors = [phaseOffset_errors mean(nOverlap_errors)];
				phaseOffset_rts = [phaseOffset_rts mean(nOverlap_rts)];
			end
			windowLength_errors = [windowLength_errors mean(phaseOffset_errors)];
			windowLength_rts = [windowLength_rts mean(phaseOffset_rts)];
		end
		dataLength_errors = [dataLength_errors mean(windowLength_errors)];
		dataLength_rts= [dataLength_rts mean(windowLength_rts)];
	end

	save('welch_errors.mat','dataLength_errors');
	save('welch_rts.mat','dataLength_rts');
	close all
	figure;
	plot(dataLengthSecs,dataLength_errors);
end



%%
% close all
% figure;
% plot(fft_errors);
%plot(fft_dls,fft_errors);
%hold on; plot(welch_dls,welch_errors);


% legend('FFT','Welch')
% figure;
% plot(welch_rts);

%% Regina
% plot FFT vs Welch on the same plot, save the figures, use full range of
% values, 1:0.25:200. Also plot wls for welch, or figure out trend.

%%
% pmusic(data,4,nfft,sampleRate)
%             FFTX = [];
%             for olp=overlapPercent
%                 stepsize = (1-olp)*windowLengthSamples;
%                 maxK=dataLengthSamples/stepsize-1;
%                 for K = 0:maxK-1
%                     U = sum(hamming(nfft))/nfft;
%                     startwin = stepsize*K + 1;
%                     endwin = stepsize*K + windowLengthSamples;
%                     FFTK = fft(hamming(nfft)'.*data(startwin:endwin));
%                     magFFTK = (1/(windowLengthSamples*U))*abs(FFTK).^2; %Normalize
%                     phaFFTK = angle(FFTK);
%                     dbFFTK = 20*log10(magFFTK);
%                     dbFFTK = dbFFTK - max(dbFFTK);
%                     dbFFTK = dbFFTK./maxK; %Average
%                     FFTX = [FFTX dbFFTK];
%                 end
%             end
%             welch_f= linspace(-.5,.5,nfft);
%overlapSecs = 0;
%nOverlap = overlapSecs*sampleRate;
%             amp = sqrt(FFTX);

				%     plot(welch_f,amp);
				%     xlim([10.5 10.56])
				%     ylabel('Amplitude')
				%     title(['Data Length = ', num2str(welch_dls),' sec'])
				%     pause(0.25)