class Break3 {
    public static void main(String[] args) {
        int x = 7;
        block: {
            System.out.println("in block");
            if (x == 7) {
                break block;
            }
            System.out.println("not reached");
        }
        System.out.println("after block");
    }
}
