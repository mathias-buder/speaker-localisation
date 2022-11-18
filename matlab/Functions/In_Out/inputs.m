% INPUTS.M
%
% US 20.2.91, revised 25-Mai-2010, first blank please removed !
%
% Description:
% read input argument or vector with default option by typing RETURN
% Example : N=inputs('degree of the filter',2);  ...reads N=2 if RETURN
%
%
% function out=inputs(str,inold);
function out=inputs(str,inold)

% changed 22.07.2012 MM
%str=['please input ',str,' ['];
str=[str,' ['];
strend='] : ';
for kx=1:length(inold)
	if kx~=length(inold)
		str=[str,num2str(inold(kx)),','];
	else
		str=[str,num2str(inold(kx))];
    end
end
str=[str,strend];

if ischar(inold)
	out=input(str,'s');
else
	out=input(str);
end % if

if isempty(out),
	out=inold;
end

return
