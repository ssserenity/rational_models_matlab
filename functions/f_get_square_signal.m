function u = f_get_square_signal(size)
t = 0:1:size-1;
u = (square(0.06*pi*t)');
end