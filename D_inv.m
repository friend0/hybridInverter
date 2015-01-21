function inD = D(x)

global R
global L
global C
global vdc
global Rload
global a
global b

global epsilon
global cmid
global cin
global cout

global i;
global h;
global t;
global Vz0
global w
global err


% state
p = x(1); %controller selection
q = x(2); % switch position
il = x(3); % inductor current
vc = x(4); % capacitor voltage

% tracking band parameters
%{
epsilon = 0.1;
cmid = 1;
cin = cmid - epsilon;
cout = cmid + epsilon;
Vz = (z1/a)^2 + (z2/b)^2;

%}

% trajectory function
Vz0 = (il/a)^2 + (vc/b)^2;

% error band and parameter
if ((abs(Vz0 - cout) < err) && ((il >= 0) && (il <= err)) && (vc <= 0))
    M1 = 1;
else
    M1 = 0;
end
if ((abs(Vz0 - cout) < err) && ((il >= -err) && (il <= 0)) && (vc >= 0))
    M2 = 1;
else
    M2 = 0;
end

%{
% forward invariance jump set logic
if ((abs(Vz0 - cin) < err) && ((il*q) <= 0) && (q ~= 0))
    Dfw = 1;
elseif ((abs(Vz0 - cout) < err) && ((il*q) >= 0) && (q ~= 0))
    Dfw = 1;
elseif ((abs(Vz0 - cout) < err) && ~M1 && ~M2 && (q == 0))
    Dfw = 1;
elseif ((abs(Vz0 - cin) < err) && (q == 0))
    Dfw = 1;
else
    Dfw = 0;
end

if (Dfw && (p == 1))
    Dfw = 1;
else
    Dfw = 0;
end



% global convergence jump set logic
if ((Vz0 <= cout) && (Vz0 >= cin) && (p == 2))
    Dg = 1;
else
    Dg = 0;
end

%closed-loop system jump set
if (Dfw || Dg)
    inD = 1; % report jump
else
    inD = 0; %do not report jump
end

%}



%======================
%For the Hs Controller
%======================

%p == 1 -> Hfw in the loop
%p == 2 -> Hg in the loop


if(p == 2)
    if((Vz0 >= cin) && (Vz0 <= cout))
        inD = 1;
    end
else
    inD = 0;    
end

%======================
%For the Hfw Controller
%======================
if(p == 1)
    if(q ~= 0)
       if( (abs(Vz0-cin) <= err) && (il*q <= 0))
           inD = 1;
       elseif( (abs(Vz0-cout) <= err) && (il*q >= 0))
           inD = 1;
       end
    elseif (q == 0)
        if( (abs(Vz0-cin) <= err) && (q == 0))
            inD = 1;
        end   
    end
end

%======================
%For the Hg Controller
%======================
if(p == 2)
    if((Vz0 >= cin) && (Vz0 <= cout))
        inD = 1;
    else
        inD = 0;
    end
end

%p
inD
end