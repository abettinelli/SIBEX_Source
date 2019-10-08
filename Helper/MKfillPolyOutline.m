% Michael Kantor, 2008

% fills polygon outline for missing points

function [xOut, yOut]=MKfillPolyOutline(x, y, x_pixdim, y_pixdim)

x=single([x(:); x(1)]);
y=single([y(:); y(1)]);
lx=length(x);

% allocate some space, hopefully enough
xOut=zeros(lx*2, 1, 'single');
yOut=zeros(lx*2, 1, 'single');

nPoints=0;

corner=sqrt(x_pixdim^2 + y_pixdim^2) * 1.05;

for i=1:lx-1
    A=[x(i), y(i)];
    B=[x(i+1), y(i+1)];
    if calculateDistance(A, B) < corner
        % points are adjacent, no interpolation needed
        nPoints=nPoints+1;
        xOut(nPoints)=A(1);
        yOut(nPoints)=A(2);
    else
        % points are distant, interpolate
        if abs(A(1)-B(1))>=abs(A(2)-B(2))
            % along X
            if A(1)<B(1)
                % left->right
                xx=single(round(A(1)):x_pixdim:round(B(1)));
            else
                % left<-right
                xx=single(round(A(1)):-x_pixdim:round(B(1)));
            end

            % single precision operations
            A=round(A);
            B=round(B);
            m=(B(2)-A(2))/(B(1)-A(1));
            % b=(A(2)-(A(1)*m));
            if m == 0
                % horizontal line
                yy=A(2)*ones(size(xx));
            else
                yy=A(2)+((xx-A(1))*m);
            end
        else
            % along Y
            if A(2)>B(2)
                % top->bottom
                yy=single(round(A(2)):-y_pixdim:round(B(2)));
            else
                % top<-bottom
                yy=single(round(A(2)):y_pixdim:round(B(2)));
            end

            % single precision operations
            A(2)=round(A(2));
            B(2)=round(B(2));
			if (B(1)-A(1)) ~= 0
				m=(B(2)-A(2))/(B(1)-A(1));
			else
				m=Inf;
			end

            if isinf(m)
                % vertical line
                xx=A(1)*ones(size(yy));
            else
                xx=A(1)+((yy-A(2))/m);
            end
        end

        % xx and yy reach from A to B, expecting B to be added at the next
        % iteration of the outer loop, as the next A

        L=length(xx)-1;
        xOut(nPoints+1:nPoints+L)=xx(1:L);
        yOut(nPoints+1:nPoints+L)=yy(1:L);
        nPoints=nPoints+L;
    end
end

% trim, in case allocated space was excessive
xOut=xOut(1:nPoints);
yOut=yOut(1:nPoints);


function  d = calculateDistance(pA, pB) 
d=sqrt((pB(1)-pA(1))^2 + (pB(2)-pA(2))^2);