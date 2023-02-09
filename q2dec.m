function y = q2dec(x,a,b,format)
% function y = q2dec(x,a,b,format)
% Convert numbers from Qa.b format to decimal
% where 'a' is the number of bits to the left of the binary point not including the sign bit
% and 'b' is the number of bits to the right of the binary point.
% An example of a Q0.15 (also called Q15) number is 1.100 0000 0000 0000 = -1 + 0.5 = -0.5.
% x (string matrix) input in Qa.b format (one number on each row)
% a (scalar) number of bits to the left of the binary point not including the sign bit
%                (Optional, default is 0)
% b (scalar) number of bits to the right of the binary point 
%                (Optional, default is 15)
% format (string) format of input 'bin' or 'hex' (optional, default 'hex')
% y (scalar) output in decimal

% written by Joe Hoffbeck, 2/5/17

% L is the number of hex or binary numbers in the input
% N is the number of digits in each input number
[L,N] = size(x);  

% default is a = 0
if nargin < 2
	a = 0;
end
if isempty(a)
	a = 0;
end

% default is b = 15
if nargin < 3
	b = 15;
end
if isempty(a)
	b = 15;
end

% default is hex input
if nargin < 4
    format = 'hex';
end
format = lower(format);  % convert to lower case (to also accept 'HEX' or 'BIN')

% check for errors in format
if ~(strcmp(format,'bin') || strcmp(format,'hex'))
	error('q2dec: input format must be either ''bin'' or ''hex''')
end

% check for errors in binary input
if strcmp(format,'bin')
    if N ~= a + b + 1
	st = ['q2dec: binary input should have ', num2str(a + b + 1), ' bits'];
        error(st)
    end
    if ~all(all(x=='0' | x=='1'))
        error('q2dec: binary input must be a string with either ''0'' or ''1''')
    end        
end

% convert to binary (if needed)
if strcmp(format,'hex')
    if round((a + b + 1)/4) ~= (a + b + 1)/4
	st = 'q2dec: hex input not supported for these values of a and b because the number of bits is not an integer multiple of 4.';
	error(st)
    end
    if N ~= (a + b + 1)/4
	st = ['q2dec: input should be ', num2str((a + b + 1)/4), ' hex characters'];
        error(st)
    end
    x = dec2bin(hex2dec(x),4*N);
end

k = a:-1:-b;  % bit position for bits
w = 2.^k;  % weight of bits
w(1) = -w(1);	% change weight of sign bit

y = zeros(L,1);
for i = 1:L
	y(i) = (x(i,:)-'0')*w'; % multiply bits by weights and add up 
end